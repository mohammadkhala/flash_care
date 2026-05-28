<?php

namespace App\Http\Controllers\Therapist;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AssessmentController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $assessments = DB::table('assessments')
            ->where('therapist_id', $request->user()->therapist->id)
            ->orderByDesc('created_at')
            ->paginate(20);
        return response()->json($assessments);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'patient_id' => 'nullable|integer',
            'type'       => 'required|in:phq9,gad7',
            'answers'    => 'required|array',
            'score'      => 'required|integer|min:0|max:27',
            'severity'   => 'required|string|max:100',
        ]);

        $id = DB::table('assessments')->insertGetId(array_merge($validated, [
            'therapist_id' => $request->user()->therapist->id,
            'answers'      => json_encode($validated['answers']),
            'created_at'   => now(),
            'updated_at'   => now(),
        ]));

        return response()->json(['id' => $id, 'message' => 'تم حفظ التقييم'], 201);
    }
}
