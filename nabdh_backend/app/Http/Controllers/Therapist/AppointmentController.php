<?php

namespace App\Http\Controllers\Therapist;

use App\Http\Controllers\Controller;
use App\Models\Appointment;
use App\Services\AppointmentService;
use App\Services\FcmService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AppointmentController extends Controller
{
    public function __construct(
        private AppointmentService $appointmentService,
        private FcmService $fcmService,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'status' => 'nullable|in:pending,confirmed,completed,cancelled_by_patient,cancelled_by_therapist',
            'date' => 'nullable|date',
            'per_page' => 'nullable|integer|min:1|max:50',
        ]);

        $query = $request->user()->therapist->appointments()
            ->with(['patient', 'clinic', 'sessionNote'])
            ->orderBy('scheduled_at', 'desc');

        if ($request->status) $query->where('status', $request->status);
        if ($request->date)   $query->whereDate('scheduled_at', $request->date);
        if ($request->filter === 'today') $query->whereDate('scheduled_at', now()->toDateString());

        return response()->json($query->paginate($request->per_page ?? 15));
    }

    public function show(Appointment $appointment): JsonResponse
    {
        abort_if($appointment->therapist_id !== request()->user()->therapist->id, 403);
        return response()->json($appointment->load(['patient.user', 'clinic', 'sessionNote']));
    }

    public function getNotes(Appointment $appointment): JsonResponse
    {
        abort_if($appointment->therapist_id !== request()->user()->therapist->id, 403);
        return response()->json(['note' => $appointment->sessionNote]);
    }

    public function saveNotes(Request $request, Appointment $appointment): JsonResponse
    {
        abort_if($appointment->therapist_id !== request()->user()->therapist->id, 403);
        $request->validate([
            'subjective' => 'nullable|string',
            'objective'  => 'nullable|string',
            'assessment' => 'nullable|string',
            'plan'       => 'nullable|string',
            'pain_scale' => 'nullable|integer|min:0|max:10',
        ]);
        $note = $appointment->sessionNote()->updateOrCreate(
            ['appointment_id' => $appointment->id],
            $request->only(['subjective', 'objective', 'assessment', 'plan', 'pain_scale'])
        );
        return response()->json(['note' => $note]);
    }

    public function confirm(Appointment $appointment): JsonResponse
    {
        abort_if($appointment->therapist_id !== request()->user()->therapist->id, 403);
        abort_if(!$appointment->isPending(), 422, 'لا يمكن تأكيد هذا الموعد');

        $this->appointmentService->confirmAppointment($appointment);
        return response()->json(['message' => 'تم تأكيد الموعد']);
    }

    public function cancel(Request $request, Appointment $appointment): JsonResponse
    {
        $request->validate(['reason' => 'nullable|string|max:500']);
        abort_if($appointment->therapist_id !== $request->user()->therapist->id, 403);
        abort_if($appointment->isCompleted(), 422, 'لا يمكن إلغاء موعد مكتمل');

        $appointment->update([
            'status' => 'cancelled_by_therapist',
            'cancellation_reason' => $request->reason,
        ]);

        $this->fcmService->send(
            $appointment->patient->user,
            'تم إلغاء الموعد',
            "تم إلغاء موعدك مع {$appointment->therapist->full_name}",
            ['appointment_id' => (string) $appointment->id],
            'appointment_cancelled'
        );

        return response()->json(['message' => 'تم إلغاء الموعد']);
    }

    public function complete(Request $request, Appointment $appointment): JsonResponse
    {
        $request->validate([
            'subjective' => 'nullable|string',
            'objective' => 'nullable|string',
            'assessment' => 'nullable|string',
            'plan' => 'nullable|string',
            'pain_scale' => 'nullable|integer|min:0|max:10',
        ]);

        abort_if($appointment->therapist_id !== $request->user()->therapist->id, 403);
        abort_if(!$appointment->isConfirmed(), 422, 'الموعد يجب أن يكون مؤكداً');

        $appointment->update(['status' => 'completed']);

        if ($request->hasAny(['subjective', 'objective', 'assessment', 'plan'])) {
            $appointment->sessionNote()->create($request->only(['subjective', 'objective', 'assessment', 'plan', 'pain_scale']));
        }

        $this->fcmService->send(
            $appointment->patient->user,
            'انتهت الجلسة',
            'يرجى تقييم جلستك مع المعالج',
            ['appointment_id' => (string) $appointment->id],
            'session_completed'
        );

        return response()->json(['message' => 'تم إكمال الجلسة']);
    }

    public function generateAgoraToken(Appointment $appointment): JsonResponse
    {
        abort_if($appointment->therapist_id !== request()->user()->therapist->id, 403);
        abort_if($appointment->type !== 'online', 422);

        $channel = $appointment->agora_channel ?? 'nabdh_' . $appointment->id;
        $appointment->update(['agora_channel' => $channel]);

        return response()->json([
            'channel' => $channel,
            'app_id' => config('services.agora.app_id'),
        ]);
    }
}
