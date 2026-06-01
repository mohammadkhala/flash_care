<?php

namespace App\Http\Controllers\Therapist;

use App\Http\Controllers\Controller;
use App\Models\Clinic;
use App\Models\TherapistSchedule;
use App\Models\TherapistUnavailability;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ScheduleController extends Controller
{
    // ── Schedules ─────────────────────────────────────────────────────────────

    /**
     * GET /therapist/schedules
     * Return the therapist's full weekly schedule grouped by day.
     */
    public function index(Request $request): JsonResponse
    {
        $therapist = $request->user()->therapist;

        $schedules = TherapistSchedule::where('therapist_id', $therapist->id)
            ->orderBy('day_of_week')
            ->orderBy('type')
            ->orderBy('start_time')
            ->get();

        $unavailabilities = TherapistUnavailability::where('therapist_id', $therapist->id)
            ->where('date', '>=', now()->toDateString())
            ->orderBy('date')
            ->get();

        return response()->json([
            'schedules'       => $schedules,
            'unavailabilities' => $unavailabilities,
        ]);
    }

    /**
     * PUT /therapist/schedules
     * Replace the therapist's entire schedule.
     * Accepts an array of schedule slots.
     *
     * Body: { slots: [ { day_of_week, type, start_time, end_time, slot_duration, is_active }, ... ] }
     */
    public function update(Request $request): JsonResponse
    {
        $request->validate([
            'slots'                  => 'required|array',
            'slots.*.day_of_week'    => 'required|integer|between:0,6',
            'slots.*.type'           => 'required|in:in_person,online',
            'slots.*.start_time'     => 'required|date_format:H:i',
            'slots.*.end_time'       => 'required|date_format:H:i|after:slots.*.start_time',
            'slots.*.slot_duration'  => 'required|integer|in:30,45,60,90,120',
            'slots.*.is_active'      => 'boolean',
        ]);

        $therapist = $request->user()->therapist;

        DB::transaction(function () use ($therapist, $request) {
            // Delete existing schedule
            TherapistSchedule::where('therapist_id', $therapist->id)->delete();

            // Insert new slots
            $now = now();
            $rows = collect($request->slots)->map(fn($slot) => [
                'therapist_id'  => $therapist->id,
                'day_of_week'   => $slot['day_of_week'],
                'type'          => $slot['type'],
                'start_time'    => $slot['start_time'],
                'end_time'      => $slot['end_time'],
                'slot_duration' => $slot['slot_duration'],
                'is_active'     => $slot['is_active'] ?? true,
                'created_at'    => $now,
                'updated_at'    => $now,
            ])->toArray();

            if (!empty($rows)) {
                TherapistSchedule::insert($rows);
            }

            // Update therapist accepts_online / accepts_in_person flags
            $types = collect($request->slots)->where('is_active', '!=', false)->pluck('type')->unique();
            $therapist->update([
                'accepts_online'    => $types->contains('online'),
                'accepts_in_person' => $types->contains('in_person'),
            ]);
        });

        return response()->json([
            'message' => 'تم حفظ جدول الدوام بنجاح',
            'schedules' => TherapistSchedule::where('therapist_id', $therapist->id)
                ->orderBy('day_of_week')->orderBy('start_time')->get(),
        ]);
    }

    // ── Unavailability ────────────────────────────────────────────────────────

    /**
     * POST /therapist/unavailability
     * Mark a day (or time range) as unavailable.
     */
    public function addUnavailability(Request $request): JsonResponse
    {
        $request->validate([
            'date'       => 'required|date|after_or_equal:today',
            'start_time' => 'nullable|date_format:H:i',
            'end_time'   => 'nullable|date_format:H:i|after:start_time',
            'reason'     => 'nullable|string|max:255',
        ]);

        $therapist = $request->user()->therapist;

        $unavailability = TherapistUnavailability::create([
            'therapist_id' => $therapist->id,
            'date'         => $request->date,
            'start_time'   => $request->start_time,
            'end_time'     => $request->end_time,
            'reason'       => $request->reason,
        ]);

        return response()->json(['unavailability' => $unavailability], 201);
    }

    /**
     * DELETE /therapist/unavailability/{id}
     * Remove an unavailability entry.
     */
    public function removeUnavailability(Request $request, int $id): JsonResponse
    {
        $therapist = $request->user()->therapist;

        $unavailability = TherapistUnavailability::where('id', $id)
            ->where('therapist_id', $therapist->id)
            ->firstOrFail();

        $unavailability->delete();

        return response()->json(['message' => 'تم الحذف']);
    }

    // ── Clinics ───────────────────────────────────────────────────────────────

    /**
     * GET /therapist/clinics
     */
    public function clinicsIndex(Request $request): JsonResponse
    {
        $clinics = Clinic::where('therapist_id', $request->user()->therapist->id)->get();
        return response()->json($clinics);
    }

    /**
     * POST /therapist/clinics
     */
    public function clinicsStore(Request $request): JsonResponse
    {
        $request->validate([
            'name'      => 'required|string|max:255',
            'address'   => 'nullable|string|max:500',
            'latitude'  => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'phone'     => 'nullable|string|max:20',
        ]);

        $clinic = Clinic::create([
            'therapist_id' => $request->user()->therapist->id,
            ...$request->only('name', 'address', 'latitude', 'longitude', 'phone'),
        ]);

        return response()->json(['clinic' => $clinic], 201);
    }

    /**
     * PUT /therapist/clinics/{clinic}
     */
    public function clinicsUpdate(Request $request, Clinic $clinic): JsonResponse
    {
        abort_if($clinic->therapist_id !== $request->user()->therapist->id, 403);

        $request->validate([
            'name'      => 'sometimes|string|max:255',
            'address'   => 'nullable|string|max:500',
            'latitude'  => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'phone'     => 'nullable|string|max:20',
        ]);

        $clinic->update($request->only('name', 'address', 'latitude', 'longitude', 'phone'));

        return response()->json(['clinic' => $clinic]);
    }

    /**
     * DELETE /therapist/clinics/{clinic}
     */
    public function clinicsDestroy(Request $request, Clinic $clinic): JsonResponse
    {
        abort_if($clinic->therapist_id !== $request->user()->therapist->id, 403);
        $clinic->delete();
        return response()->json(['message' => 'تم حذف العيادة']);
    }
}
