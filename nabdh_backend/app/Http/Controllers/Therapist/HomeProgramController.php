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
            'exercises.*.media_name' => 'nullable|string|max:255',
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
            'file' => 'required|file|max:512000', // 500MB
            'type' => 'required|in:image,video,file',
        ]);

        $directory = match ($request->type) {
            'image' => 'exercises/images',
            'video' => 'exercises/videos',
            default => 'exercises/files',
        };

        $path = $request->file('file')->store($directory, 'public');

        return response()->json([
            'media_url' => $this->publicUrl($request, $path),
            'media_name' => $request->file('file')->getClientOriginalName(),
            'media_size' => $request->file('file')->getSize(),
        ]);
    }

    /**
     * Build an absolute URL for a stored public file using the *incoming request*
     * host rather than APP_URL, so uploads keep working even when APP_URL is
     * stale or points at localhost on the server.
     */
    private function publicUrl(Request $request, string $path): string
    {
        $relative = Storage::disk('public')->url($path);

        // Storage::url() may already return an absolute URL (built from APP_URL).
        // Reduce it to its path so we can re-anchor it on the real request host.
        if (str_contains($relative, '://')) {
            $relative = parse_url($relative, PHP_URL_PATH) ?: '/storage/' . $path;
        }

        return rtrim($request->getSchemeAndHttpHost(), '/') . '/' . ltrim($relative, '/');
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

    public function update(Request $request, HomeProgram $program): JsonResponse
    {
        abort_if($program->therapist_id !== $request->user()->therapist->id, 403);
        $request->validate([
            'title'       => 'sometimes|required|string|max:200',
            'description' => 'nullable|string',
            'start_date'  => 'sometimes|required|date',
            'end_date'    => 'nullable|date',
            'exercises'                => 'sometimes|array|min:1',
            'exercises.*.id'           => 'nullable|integer',
            'exercises.*.title'        => 'required_with:exercises|string',
            'exercises.*.description'  => 'nullable|string',
            'exercises.*.sets'         => 'nullable|integer|min:1',
            'exercises.*.reps'         => 'nullable|integer|min:1',
            'exercises.*.duration_seconds' => 'nullable|integer',
            'exercises.*.frequency'    => 'nullable|string',
            'exercises.*.media_type'   => 'nullable|in:none,image,video,file,link',
            'exercises.*.media_url'    => 'nullable|string',
            'exercises.*.media_name'   => 'nullable|string|max:255',
            'exercises.*.order'        => 'nullable|integer',
        ]);

        $program->update($request->only(['title', 'description', 'start_date', 'end_date']));

        // When the client sends an exercises array it represents the full desired
        // list. Exercises carrying an `id` are updated in place rather than
        // recreated, so the patient's completion history survives an edit;
        // only exercises absent from the payload are removed.
        if ($request->has('exercises')) {
            $keptIds = [];

            foreach ($request->exercises as $i => $exerciseData) {
                $attributes = array_merge($exerciseData, ['order' => $exerciseData['order'] ?? $i]);
                unset($attributes['id']);

                $existing = isset($exerciseData['id'])
                    ? $program->exercises()->find($exerciseData['id'])
                    : null;

                if ($existing) {
                    $existing->update($attributes);
                    $keptIds[] = $existing->id;
                } else {
                    $keptIds[] = $program->exercises()->create($attributes)->id;
                }
            }

            $program->exercises()->whereNotIn('id', $keptIds)->delete();
        }

        return response()->json(['program' => $program->load('exercises')]);
    }

    public function destroy(HomeProgram $program): JsonResponse
    {
        abort_if($program->therapist_id !== request()->user()->therapist->id, 403);
        $program->delete();
        return response()->json(['message' => 'تم حذف البرنامج']);
    }
}
