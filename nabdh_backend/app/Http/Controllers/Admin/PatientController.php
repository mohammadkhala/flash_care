<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\FcmService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class PatientController extends Controller
{
    public function __construct(private FcmService $fcmService) {}

    public function index(Request $request)
    {
        $query = User::where('type', 'patient')
            ->with(['patient' => fn($q) => $q->withCount('appointments')])
            ->withCount(['patient as appointments_count' => fn($q) =>
                $q->join('appointments', 'patients.id', '=', 'appointments.patient_id')
            ]);

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('phone', 'like', "%{$search}%")
                  ->orWhereHas('patient', fn($p) =>
                      $p->where('full_name', 'like', "%{$search}%")
                  );
            });
        }

        if ($request->filled('status')) {
            $query->where('is_active', $request->status === 'active');
        }

        $users = $query->latest()->paginate(20)->withQueryString();

        return view('admin.patients.index', compact('users'));
    }

    public function show(User $user)
    {
        abort_unless($user->type === 'patient', 404);
        $user->load([
            'patient.appointments.therapist',
            'patient.homePrograms',
        ]);
        return view('admin.patients.show', compact('user'));
    }

    public function edit(User $user)
    {
        abort_unless($user->type === 'patient', 404);
        $user->load('patient');
        return view('admin.patients.edit', compact('user'));
    }

    public function update(Request $request, User $user)
    {
        abort_unless($user->type === 'patient', 404);

        $request->validate([
            'full_name'               => 'required|string|max:100',
            'gender'                  => 'nullable|in:male,female',
            'city'                    => 'nullable|string|max:100',
            'date_of_birth'           => 'nullable|date|before:today',
            'medical_history'         => 'nullable|string|max:3000',
            'allergies'               => 'nullable|string|max:500',
            'emergency_contact_name'  => 'nullable|string|max:100',
            'emergency_contact_phone' => 'nullable|string|max:20',
            'phone'                   => 'nullable|string|max:20',
            'phone_country_code'      => 'nullable|string|max:10',
        ]);

        $patient = $user->patient;
        if ($patient) {
            $patient->update($request->only([
                'full_name', 'gender', 'city', 'date_of_birth',
                'medical_history', 'allergies',
                'emergency_contact_name', 'emergency_contact_phone',
            ]));

            // Avatar upload
            if ($request->hasFile('avatar')) {
                if ($patient->avatar) Storage::disk('public')->delete($patient->avatar);
                $path = $request->file('avatar')->store('avatars/patients', 'public');
                $patient->update(['avatar' => $path]);
            }
        }

        if ($request->filled('phone')) {
            $user->update([
                'phone'              => $request->phone,
                'phone_country_code' => $request->phone_country_code ?? '+970',
            ]);
        }

        return redirect()->route('admin.patients.show', $user)
            ->with('success', 'تم تحديث بيانات المريض بنجاح ✅');
    }

    public function notify(Request $request, User $user)
    {
        abort_unless($user->type === 'patient', 404);

        $request->validate([
            'title' => 'required|string|max:100',
            'body'  => 'required|string|max:500',
        ]);

        $this->fcmService->send(
            $user,
            $request->title,
            $request->body,
            ['type' => 'admin_notification'],
            'admin_notification'
        );

        return back()->with('success', 'تم إرسال الإشعار للمريض ✅');
    }

    public function toggleActive(User $user)
    {
        abort_unless($user->type === 'patient', 404);
        $user->update(['is_active' => !$user->is_active]);
        return back()->with('success', 'تم تحديث الحالة');
    }

    public function destroy(User $user)
    {
        abort_unless($user->type === 'patient', 404);

        $patient = $user->patient;
        if ($patient) {
            $patient->appointments()->delete();
            $patient->reviews()->delete();
            $patient->homePrograms()->delete();
            $patient->delete();
        }

        $user->tokens()->delete();
        $user->delete();

        return redirect()->route('admin.patients.index')
            ->with('success', 'تم حذف حساب المريض نهائياً');
    }
}
