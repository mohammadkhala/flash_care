<?php

namespace App\Http\Controllers\Patient;

use App\Http\Controllers\Controller;
use App\Models\PatientGoal;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GoalController extends Controller
{
    /**
     * GET /patient/goals
     * List current patient's goals with progress logs.
     */
    public function index(Request $request): JsonResponse
    {
        $patient = $request->user()->patient;

        $goals = PatientGoal::with(['progressLogs', 'therapist'])
            ->where('patient_id', $patient->id)
            ->latest()
            ->get()
            ->map(fn($g) => $this->format($g));

        return response()->json($goals);
    }

    /**
     * GET /patient/goals/{goal}
     * Single goal with full progress history.
     */
    public function show(Request $request, PatientGoal $goal): JsonResponse
    {
        abort_if($goal->patient_id !== $request->user()->patient->id, 403);
        $goal->load(['progressLogs', 'therapist']);
        return response()->json($this->format($goal));
    }

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
            'therapist_name'   => $goal->therapist?->full_name,
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
