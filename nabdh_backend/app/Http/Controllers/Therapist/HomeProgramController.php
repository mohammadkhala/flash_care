<?php

namespace App\Http\Controllers\Therapist;

use App\Http\Controllers\Controller;
use App\Models\HomeProgram;
use App\Models\ProgramExercise;
use App\Services\FcmService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class HomeProgramController extends Controller
{
    public function __construct(private FcmService $fcmService) {}

    public function index(Request $request): JsonResponse
    {
        $programs = $request->user()->therapist
            ->homePrograms()
            ->with(['patient', 'exercises'])
            ->orderByDesc('created_at')
            ->paginate(15);

        return response()->json($programs);
    }

    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'patient_id' => 'required|exists:patients,id',
            'title' => 'required|string|max:200',
            'description' => 'nullable|string',
            'start_date' => 'required|date',
            'end_date' => 'nullable|date|after:start_date',
            'exercises' => 'required|array|min:1',
            'exercises.*.title' => 'required|string',
            'exercises.*.description' => 'nullable|string',
            'exercises.*.sets' => 'nullable|integer|min:1',
            'exercises.*.reps' => 'nullable|integer|min:1',
            'exercises.*.duration_seconds' => 'nullable|integer',
            'exercises.*.frequency' => 'nullable|string',
            'exercises.*.media_type' => 'nullable|in:none,image,video,file,link',
            'exercises.*.media_url' => 'nullable|string',
            'exercises.*.order' => 'nullable|integer',
        ]);

        $program = $request->user()->therapist->homePrograms()->create(
            $request->only(['patient_id', 'title', 'description', 'start_date', 'end_date'])
        );

        foreach ($request->exercises as $i => $exerciseData) {
            $program->exercises()->create(array_merge($exerciseData, ['order' => $exerciseData['order'] ?? $i]));
        }

        $this->fcmService->send(
            $program->patient->user,
            'برنامج منزلي جديد',
            "أرسل لك معالجك برنامجاً منزلياً: {$program->title}",
            ['program_id' => (string) $program->id],
            'new_home_program'
        );

        return response()->json(['program' => $program->load('exercises')], 201);
    }

    public function uploadExerciseMedia(Request $request): JsonResponse
    {
        $request->validate([
            'file' => 'required|file|max:102400', // 100MB
            'type' => 'required|in:image,video,file',
        ]);

        $directory = match ($request->type) {
            'image' => 'exercises/images',
            'video' => 'exercises/videos',
            default => 'exercises/files',
        };

        $path = $request->file('file')->store($directory, 'public');

        return response()->json([
            'media_url' => Storage::disk('public')->url($path),
            'media_name' => $request->file('file')->getClientOriginalName(),
            'media_size' => $request->file('file')->getSize(),
        ]);
    }

    public function patientPrograms(Request $request, int $patientId): JsonResponse
    {
        $programs = $request->user()->therapist
            ->homePrograms()
            ->where('patient_id', $patientId)
            ->with(['exercises.completions'])
            ->orderByDesc('created_at')
            ->get();

        return response()->json(['programs' => $programs]);
    }

    public function destroy(HomeProgram $program): JsonResponse
    {
        abort_if($program->therapist_id !== request()->user()->therapist->id, 403);
        $program->delete();
        return response()->json(['message' => 'تم حذف البرنامج']);
    }
}
