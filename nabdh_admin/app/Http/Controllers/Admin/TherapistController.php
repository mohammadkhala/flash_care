<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Therapist;
use Illuminate\Http\Request;

class TherapistController extends Controller
{
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
            'appointments' => fn($q) => $q->latest()->limit(10),
            'reviews' => fn($q) => $q->latest()->limit(5),
        ]);

        return view('admin.therapists.show', compact('therapist'));
    }

    public function approve(Therapist $therapist)
    {
        $therapist->update(['is_approved' => true, 'approved_at' => now()]);

        // Notify via backend API (or direct FCM)
        session()->flash('success', "تم قبول الأخصائي {$therapist->full_name}");
        return back();
    }

    public function reject(Request $request, Therapist $therapist)
    {
        $request->validate(['reason' => 'required|string|max:500']);
        $therapist->update(['is_approved' => false]);

        session()->flash('success', 'تم رفض الطلب وإشعار الأخصائي');
        return back();
    }

    public function toggleFeatured(Therapist $therapist)
    {
        $therapist->update(['is_featured' => !$therapist->is_featured]);
        return response()->json(['is_featured' => $therapist->is_featured]);
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
