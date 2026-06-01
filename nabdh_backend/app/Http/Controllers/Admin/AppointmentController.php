<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Appointment;
use App\Services\FcmService;
use Illuminate\Http\Request;

class AppointmentController extends Controller
{
    public function __construct(private FcmService $fcmService) {}

    public function index(Request $request)
    {
        $query = Appointment::with(['therapist', 'patient'])
            ->latest('scheduled_at');

        if ($request->status) $query->where('status', $request->status);
        if ($request->type)   $query->where('type', $request->type);
        if ($request->date)   $query->whereDate('scheduled_at', $request->date);

        if ($request->search) {
            $query->where(function ($q) use ($request) {
                $q->whereHas('therapist', fn($t) => $t->where('full_name', 'like', "%{$request->search}%"))
                  ->orWhereHas('patient',  fn($p) => $p->where('full_name', 'like', "%{$request->search}%"));
            });
        }

        $appointments = $query->paginate(20)->withQueryString();

        $summary = [
            'total'     => Appointment::count(),
            'pending'   => Appointment::where('status', 'pending')->count(),
            'confirmed' => Appointment::where('status', 'confirmed')->count(),
            'completed' => Appointment::where('status', 'completed')->count(),
            'cancelled' => Appointment::where('status', 'like', 'cancelled%')->count(),
        ];

        return view('admin.appointments.index', compact('appointments', 'summary'));
    }

    public function show(Appointment $appointment)
    {
        $appointment->load(['therapist.user', 'patient.user']);
        return view('admin.appointments.show', compact('appointment'));
    }

    public function updateStatus(Request $request, Appointment $appointment)
    {
        $request->validate([
            'status' => 'required|in:pending,confirmed,completed,cancelled_by_admin',
            'note'   => 'nullable|string|max:500',
        ]);

        $oldStatus = $appointment->status;
        $appointment->update(['status' => $request->status]);

        // Notify both parties
        $statusLabel = match($request->status) {
            'confirmed'          => 'مؤكد',
            'completed'          => 'مكتمل',
            'cancelled_by_admin' => 'ملغى من الإدارة',
            default              => 'معلق',
        };

        $msg = $request->note
            ? "تم تغيير حالة الموعد إلى: {$statusLabel}. ملاحظة: {$request->note}"
            : "تم تغيير حالة الموعد إلى: {$statusLabel}";

        if ($appointment->therapist?->user) {
            $this->fcmService->send(
                $appointment->therapist->user,
                'تحديث الموعد',
                $msg,
                ['type' => 'appointment_updated', 'appointment_id' => (string)$appointment->id],
                'appointment:' . $appointment->id
            );
        }

        if ($appointment->patient?->user) {
            $this->fcmService->send(
                $appointment->patient->user,
                'تحديث الموعد',
                $msg,
                ['type' => 'appointment_updated', 'appointment_id' => (string)$appointment->id],
                'appointment:' . $appointment->id
            );
        }

        return back()->with('success', "تم تغيير حالة الموعد إلى: {$statusLabel}");
    }

    public function destroy(Appointment $appointment)
    {
        $appointment->delete();
        return redirect()->route('admin.appointments.index')
            ->with('success', 'تم حذف الموعد');
    }
}
