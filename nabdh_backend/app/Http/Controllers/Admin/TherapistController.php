<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Specialization;
use App\Models\Therapist;
use App\Services\FcmService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class TherapistController extends Controller
{
    public function __construct(private FcmService $fcmService) {}

    public function index(Request $request)
    {
        $query = Therapist::with(['user', 'specializations'])
            ->withCount(['appointments', 'reviews']);

        if ($request->status === 'pending') {
            $query->where('is_approved', false);
        } elseif ($request->status === 'approved') {
            $query->where('is_approved', true);
        }

        if ($request->search) {
            $query->where('full_name', 'like', "%{$request->search}%");
        }

        $therapists = $query->latest()->paginate(15)->withQueryString();

        return view('admin.therapists.index', compact('therapists'));
    }

    public function show(Therapist $therapist)
    {
        $therapist->load([
            'user', 'specializations', 'documents',
            'appointments' => fn($q) => $q->with('patient')->latest()->limit(10),
            'reviews'      => fn($q) => $q->latest()->limit(5),
            'reels'        => fn($q) => $q->latest()->limit(6),
            'homePrograms' => fn($q) => $q->latest()->limit(5),
        ]);

        return view('admin.therapists.show', compact('therapist'));
    }

    public function edit(Therapist $therapist)
    {
        $therapist->load(['user', 'specializations']);
        $allSpecializations = Specialization::where('is_active', true)->orderBy('name_ar')->get();
        return view('admin.therapists.edit', compact('therapist', 'allSpecializations'));
    }

    public function update(Request $request, Therapist $therapist)
    {
        $request->validate([
            'full_name'               => 'required|string|max:100',
            'full_name_en'            => 'nullable|string|max:100',
            'title'                   => 'nullable|string|max:100',
            'bio'                     => 'nullable|string|max:2000',
            'bio_en'                  => 'nullable|string|max:2000',
            'city'                    => 'nullable|string|max:100',
            'gender'                  => 'nullable|in:male,female',
            'years_experience'        => 'nullable|integer|min:0|max:60',
            'degree'                  => 'nullable|string|max:100',
            'online_session_price'    => 'nullable|numeric|min:0',
            'in_person_session_price' => 'nullable|numeric|min:0',
            'session_duration'        => 'nullable|integer|min:15|max:180',
            'specializations'         => 'nullable|array',
            'specializations.*'       => 'exists:specializations,id',
            'phone'                   => 'nullable|string|max:20',
            'phone_country_code'      => 'nullable|string|max:10',
            'latitude'                => 'nullable|numeric|between:-90,90',
            'longitude'               => 'nullable|numeric|between:-180,180',
        ]);

        $therapist->update([
            'full_name'               => $request->full_name,
            'full_name_en'            => $request->full_name_en,
            'title'                   => $request->title,
            'bio'                     => $request->bio,
            'bio_en'                  => $request->bio_en,
            'city'                    => $request->city,
            'gender'                  => $request->gender,
            'years_experience'        => $request->years_experience,
            'degree'                  => $request->degree,
            'online_session_price'    => $request->online_session_price,
            'in_person_session_price' => $request->in_person_session_price,
            'session_duration'        => $request->session_duration,
            'accepts_online'          => $request->boolean('accepts_online'),
            'accepts_in_person'       => $request->boolean('accepts_in_person'),
            // Blank inputs clear the pin so the map falls back to the city centre.
            'latitude'                => $request->filled('latitude')  ? $request->latitude  : null,
            'longitude'               => $request->filled('longitude') ? $request->longitude : null,
        ]);

        // Sync specializations
        $therapist->specializations()->sync($request->input('specializations', []));

        // Update phone if changed
        if ($request->filled('phone')) {
            $therapist->user->update([
                'phone'              => $request->phone,
                'phone_country_code' => $request->phone_country_code ?? '+970',
            ]);
        }

        // Handle avatar upload
        if ($request->hasFile('avatar')) {
            if ($therapist->avatar) Storage::disk('public')->delete($therapist->avatar);
            $path = $request->file('avatar')->store('avatars/therapists', 'public');
            $therapist->update(['avatar' => $path]);
        }

        return redirect()->route('admin.therapists.show', $therapist)
            ->with('success', 'تم تحديث بيانات الأخصائي بنجاح ✅');
    }

    public function approve(Therapist $therapist)
    {
        $wasApproved = $therapist->is_approved;
        $therapist->update(['is_approved' => true, 'approved_at' => now()]);

        if (!$wasApproved && $therapist->user) {
            $this->fcmService->send(
                $therapist->user,
                'تمت الموافقة على حسابك 🎉',
                'مرحباً بك في نبض! يمكنك الآن استقبال المرضى وإدارة مواعيدك.',
                ['type' => 'account_approved'],
                'account_approved'
            );
        }

        session()->flash('success', "تم قبول الأخصائي {$therapist->full_name}");
        return back();
    }

    public function reject(Request $request, Therapist $therapist)
    {
        $request->validate(['reason' => 'required|string|max:500']);
        $therapist->update(['is_approved' => false]);

        if ($therapist->user) {
            $this->fcmService->send(
                $therapist->user,
                'تحديث حول طلبك',
                'نأسف، لم نتمكن من قبول حسابك في الوقت الحالي: ' . $request->reason,
                ['type' => 'account_rejected'],
                'account_rejected'
            );
        }

        session()->flash('success', 'تم رفض الطلب وإشعار الأخصائي');
        return back();
    }

    public function notify(Request $request, Therapist $therapist)
    {
        $request->validate([
            'title' => 'required|string|max:100',
            'body'  => 'required|string|max:500',
        ]);

        if ($therapist->user) {
            $this->fcmService->send(
                $therapist->user,
                $request->title,
                $request->body,
                ['type' => 'admin_notification'],
                'admin_notification'
            );
        }

        return back()->with('success', 'تم إرسال الإشعار للأخصائي ✅');
    }

    public function toggleFeatured(Therapist $therapist)
    {
        $therapist->update(['is_featured' => !$therapist->is_featured]);
        $label = $therapist->is_featured ? 'تم تمييز الأخصائي ⭐' : 'تم إلغاء تمييز الأخصائي';
        return back()->with('success', $label);
    }

    public function toggleActive(Therapist $therapist)
    {
        $therapist->user->update(['is_active' => !$therapist->user->is_active]);
        return back()->with('success', 'تم تحديث الحالة');
    }

    public function destroy(Therapist $therapist)
    {
        $therapist->educations()->delete();
        $therapist->certifications()->delete();
        $therapist->languages()->delete();
        $therapist->documents()->delete();
        $therapist->schedules()->delete();
        $therapist->unavailabilities()->delete();
        $therapist->clinics()->delete();
        $therapist->reels()->delete();
        $therapist->appointments()->delete();
        $therapist->reviews()->delete();

        $user = $therapist->user;
        $therapist->delete();
        $user->tokens()->delete();
        $user->delete();

        return redirect()->route('admin.therapists.index')
            ->with('success', 'تم حذف حساب الأخصائي نهائياً');
    }
}
