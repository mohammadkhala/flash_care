<?php

namespace App\Http\Controllers\Therapist;

use App\Http\Controllers\Controller;
use App\Models\GoalProgressLog;
use App\Models\PatientGoal;
use App\Services\FcmService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GoalController extends Controller
{
    public function __construct(private FcmService $fcmService) {}

    /**
     * GET /therapist/goals?patient_id=
     * List all goals for a given patient.
     */
    public function index(Request $request): JsonResponse
    {
        $request->validate(['patient_id' => 'required|exists:patients,id']);

        $therapist = $request->user()->therapist;

        $goals = PatientGoal::with(['progressLogs'])
            ->where('therapist_id', $therapist->id)
            ->where('patient_id', $request->patient_id)
            ->latest()
            ->get()
            ->map(fn($g) => $this->format($g));

        return response()->json($goals);
    }

    /**
     * POST /therapist/goals
     * Create a new goal.
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'patient_id'     => 'required|exists:patients,id',
            'title'          => 'required|string|max:255',
            'description'    => 'nullable|string|max:1000',
            'target_date'    => 'required|date|after_or_equal:today',
            'appointment_id' => 'nullable|exists:appointments,id',
        ]);

        $therapist = $request->user()->therapist;

        $goal = PatientGoal::create([
            'therapist_id'   => $therapist->id,
            'patient_id'     => $request->patient_id,
            'appointment_id' => $request->appointment_id,
            'title'          => $request->title,
            'description'    => $request->description,
            'target_date'    => $request->target_date,
            'current_progress' => 0,
            'status'         => 'active',
        ]);

        // Notify patient
        $goal->load('patient.user');
        if ($goal->patient?->user) {
            $this->fcmService->send(
                $goal->patient->user,
                'هدف علاجي جديد 🎯',
                "أضاف {$therapist->full_name} هدفاً جديداً: {$goal->title}",
                ['goal_id' => (string) $goal->id, 'type' => 'new_goal'],
                'new_goal'
            );
        }

        return response()->json(['goal' => $this->format($goal)], 201);
    }

    /**
     * GET /therapist/goals/{goal}
     */
    public function show(Request $request, PatientGoal $goal): JsonResponse
    {
        abort_if($goal->therapist_id !== $request->user()->therapist->id, 403);
        $goal->load('progressLogs');
        return response()->json($this->format($goal));
    }

    /**
     * PUT /therapist/goals/{goal}
     * Update title, description, or extend target date.
     */
    public function update(Request $request, PatientGoal $goal): JsonResponse
    {
        abort_if($goal->therapist_id !== $request->user()->therapist->id, 403);

        $request->validate([
            'title'         => 'sometimes|string|max:255',
            'description'   => 'nullable|string|max:1000',
            'target_date'   => 'sometimes|date',
            'extended_date' => 'nullable|date|after:target_date',
            'status'        => 'sometimes|in:active,completed,cancelled',
        ]);

        $goal->update($request->only('title', 'description', 'target_date', 'extended_date', 'status'));

        return response()->json(['goal' => $this->format($goal->fresh(['progressLogs']))]);
    }

    /**
     * POST /therapist/goals/{goal}/progress
     * Log a progress update and update current_progress.
     */
    public function updateProgress(Request $request, PatientGoal $goal): JsonResponse
    {
        abort_if($goal->therapist_id !== $request->user()->therapist->id, 403);

        $request->validate([
            'progress' => 'required|integer|between:0,100',
            'notes'    => 'nullable|string|max:500',
        ]);

        // Log it
        GoalProgressLog::create([
            'goal_id'   => $goal->id,
            'progress'  => $request->progress,
            'notes'     => $request->notes,
            'logged_by' => $request->user()->id,
        ]);

        // Update goal progress and auto-complete if 100%
        $newStatus = $request->progress >= 100 ? 'completed' : $goal->status;
        $goal->update([
            'current_progress' => $request->progress,
            'status'           => $newStatus,
        ]);

        // Notify patient about progress update
        $goal->load('patient.user');
        if ($goal->patient?->user) {
            $emoji = $request->progress >= 100 ? '🏆' : '📈';
            $this->fcmService->send(
                $goal->patient->user,
                "تحديث على هدفك {$emoji}",
                "هدف \"{$goal->title}\": {$request->progress}% مكتمل",
                ['goal_id' => (string) $goal->id, 'type' => 'goal_progress'],
                'goal_progress'
            );
        }

        return response()->json(['goal' => $this->format($goal->fresh(['progressLogs']))]);
    }

    /**
     * DELETE /therapist/goals/{goal}
     */
    public function destroy(Request $request, PatientGoal $goal): JsonResponse
    {
        abort_if($goal->therapist_id !== $request->user()->therapist->id, 403);
        $goal->progressLogs()->delete();
        $goal->delete();
        return response()->json(['message' => 'تم حذف الهدف']);
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private function format(PatientGoal $goal): array
    {
        return [
            'id'               => $goal->id,
            'title'            => $goal->title,
            'description'      => $goal->description,
            'target_date'      => $goal->target_date?->toDateString(),
            'extended_date'    => $goal->extended_date?->toDateString(),
            'effective_date'   => $goal->effective_date,
            'current_progress' => $goal->current_progress,
            'status'           => $goal->status,
            'patient_id'       => $goal->patient_id,
            'therapist_id'     => $goal->therapist_id,
            'appointment_id'   => $goal->appointment_id,
            'created_at'       => $goal->created_at?->toDateTimeString(),
            'progress_logs'    => $goal->progressLogs?->map(fn($l) => [
                'id'         => $l->id,
                'progress'   => $l->progress,
                'notes'      => $l->notes,
                'created_at' => $l->created_at?->toDateTimeString(),
            ])->values(),
        ];
    }
}
