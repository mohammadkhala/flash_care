<?php

namespace App\Http\Controllers\Patient;

use App\Http\Controllers\Controller;
use App\Models\Appointment;
use App\Models\Review;
use App\Services\FcmService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AppointmentController extends Controller
{
    public function __construct(private FcmService $fcmService) {}

    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'status'   => 'nullable|in:pending,confirmed,completed,cancelled_by_patient,cancelled_by_therapist',
            'per_page' => 'nullable|integer|min:1|max:50',
        ]);

        $query = $request->user()->patient->appointments()
            ->with(['therapist', 'clinic'])
            ->orderBy('scheduled_at', 'desc');

        if ($request->status) $query->where('status', $request->status);

        return response()->json($query->paginate($request->per_page ?? 15));
    }

    public function show(Request $request, Appointment $appointment): JsonResponse
    {
        abort_if($appointment->patient_id !== $request->user()->patient->id, 403);
        $appointment->load(['therapist', 'clinic', 'review']);
        return response()->json($appointment);
    }

    public function cancel(Request $request, Appointment $appointment): JsonResponse
    {
        abort_if($appointment->patient_id !== $request->user()->patient->id, 403);
        abort_if(!in_array($appointment->status, ['pending', 'confirmed']), 422);

        $appointment->update(['status' => 'cancelled_by_patient']);

        $this->fcmService->send(
            $appointment->therapist->user,
            'موعد ملغي',
            "{$request->user()->patient->full_name} ألغى الموعد",
            ['appointment_id' => (string) $appointment->id],
            'appointment_cancelled'
        );

        return response()->json(['message' => 'تم إلغاء الموعد']);
    }

    public function submitReview(Request $request, Appointment $appointment): JsonResponse
    {
        abort_if($appointment->patient_id !== $request->user()->patient->id, 403);
        abort_if($appointment->status !== 'completed', 422);

        $request->validate([
            'rating'  => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string|max:500',
        ]);

        Review::updateOrCreate(
            ['appointment_id' => $appointment->id],
            [
                'therapist_id' => $appointment->therapist_id,
                'patient_id'   => $appointment->patient_id,
                'rating'       => $request->rating,
                'comment'      => $request->comment,
                'is_visible'   => true,
                'published_at' => now(),
            ]
        );

        return response()->json(['message' => 'تم حفظ التقييم']);
    }

    public function generateAgoraToken(Appointment $appointment): JsonResponse
    {
        abort_if($appointment->patient_id !== request()->user()->patient->id, 403);
        abort_if($appointment->type !== 'online', 422);

        $channel = $appointment->agora_channel ?? 'nabdh_' . $appointment->id;
        $appointment->update(['agora_channel' => $channel]);

        return response()->json([
            'channel' => $channel,
            'app_id'  => config('services.agora.app_id'),
        ]);
    }
}
