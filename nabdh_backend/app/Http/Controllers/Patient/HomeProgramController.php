<?php

namespace App\Http\Controllers\Patient;

use App\Http\Controllers\Controller;
use App\Models\ExerciseCompletion;
use App\Models\HomeProgram;
use App\Models\PainDiary;
use App\Models\ProgramExercise;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class HomeProgramController extends Controller
{
    /**
     * GET /patient/home-programs
     * Return all active home programs for the logged-in patient.
     */
    public function index(Request $request): JsonResponse
    {
        $patientId = $request->user()->patient->id;

        $programs = HomeProgram::where('patient_id', $patientId)
            ->with([
                'therapist:id,user_id,full_name,avatar',
                'exercises' => function ($q) use ($patientId) {
                    $q->orderBy('order')
                      ->with(['completions' => function ($q2) use ($patientId) {
                          $q2->where('patient_id', $patientId)
                             ->whereDate('completed_date', today());
                      }]);
                },
            ])
            ->orderByDesc('created_at')
            ->get();

        // Append a simple `completed` boolean to each exercise (completed today)
        $programs->each(function ($program) {
            $program->exercises->each(function ($exercise) {
                $exercise->completed = $exercise->completions->isNotEmpty();
                unset($exercise->completions);
            });
        });

        return response()->json($programs);
    }

    /**
     * GET /patient/home-programs/{program}
     * Return a single program with all exercises.
     */
    public function show(Request $request, HomeProgram $program): JsonResponse
    {
        $patientId = $request->user()->patient->id;

        abort_if($program->patient_id !== $patientId, 403);

        $patientId = $request->user()->patient->id;

        $program->load([
            'therapist:id,user_id,full_name,avatar',
            'exercises' => function ($q) use ($patientId) {
                $q->orderBy('order')
                  ->with(['completions' => function ($q2) use ($patientId) {
                      $q2->where('patient_id', $patientId)
                         ->orderByDesc('completed_date')
                         ->limit(1);
                  }]);
            },
        ]);

        $program->exercises->each(function ($exercise) {
            $latest = $exercise->completions->first();
            $exercise->completed = $latest !== null;
            $exercise->last_completed_at = $latest?->completed_date;
            unset($exercise->completions);
        });

        return response()->json(['program' => $program]);
    }

    /**
     * POST /patient/exercises/{exercise}/complete
     * Mark an exercise as completed for today.
     */
    public function markComplete(Request $request, ProgramExercise $exercise): JsonResponse
    {
        $patientId = $request->user()->patient->id;

        // Verify the exercise belongs to one of this patient's programs
        $program = HomeProgram::find($exercise->home_program_id);
        abort_if(!$program || $program->patient_id !== $patientId, 403);

        $request->validate([
            'patient_note' => 'nullable|string|max:500',
            'pain_before'  => 'nullable|integer|min:0|max:10',
            'pain_after'   => 'nullable|integer|min:0|max:10',
        ]);

        $completion = ExerciseCompletion::firstOrCreate(
            [
                'program_exercise_id' => $exercise->id,
                'patient_id'          => $patientId,
                'completed_date'      => today(),
            ],
            [
                'patient_note' => $request->patient_note,
                'pain_before'  => $request->pain_before,
                'pain_after'   => $request->pain_after,
            ]
        );

        return response()->json([
            'message'    => 'تم تسجيل إتمام التمرين',
            'completion' => $completion,
        ]);
    }

    /**
     * GET /patient/pain-diary
     * Return the patient's pain diary entries.
     */
    public function painDiary(Request $request): JsonResponse
    {
        $patientId = $request->user()->patient->id;

        $entries = PainDiary::where('patient_id', $patientId)
            ->orderByDesc('date')
            ->limit(90)
            ->get();

        return response()->json(['entries' => $entries]);
    }

    /**
     * POST /patient/pain-diary
     * Log a pain diary entry.
     */
    public function logPain(Request $request): JsonResponse
    {
        $patientId = $request->user()->patient->id;

        $request->validate([
            'date'       => 'required|date',
            'pain_scale' => 'required|integer|min:0|max:10',
            'body_part'  => 'nullable|string|max:100',
            'notes'      => 'nullable|string|max:1000',
        ]);

        $entry = PainDiary::updateOrCreate(
            [
                'patient_id' => $patientId,
                'date'       => $request->date,
            ],
            [
                'pain_scale' => $request->pain_scale,
                'body_part'  => $request->body_part,
                'notes'      => $request->notes,
            ]
        );

        return response()->json([
            'message' => 'تم تسجيل مستوى الألم',
            'entry'   => $entry,
        ], 201);
    }
}
