<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Patient;
use Illuminate\Http\Request;

class PatientController extends Controller
{
    // List ALL users with type=patient (whether profile complete or not)
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

        $users = $query->latest()->paginate(20)->withQueryString();

        return view('admin.patients.index', compact('users'));
    }

    public function show(User $user)
    {
        abort_unless($user->type === 'patient', 404);
        $user->load(['patient.appointments.therapist']);
        return view('admin.patients.show', compact('user'));
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

        // Delete patient profile and all related data
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
