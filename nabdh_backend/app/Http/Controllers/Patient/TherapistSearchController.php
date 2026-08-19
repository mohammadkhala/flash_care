<?php

namespace App\Http\Controllers\Patient;

use App\Http\Controllers\Controller;
use App\Models\Therapist;
use App\Services\AppointmentService;
use App\Services\FcmService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TherapistSearchController extends Controller
{
    public function __construct(
        private AppointmentService $appointmentService,
        private FcmService $fcmService,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'search' => 'nullable|string',
            'specialization_id' => 'nullable|exists:specializations,id',
            'city' => 'nullable|string',
            'gender' => 'nullable|in:male,female',
            'type' => 'nullable|in:in_person,online',
            'sort' => 'nullable|in:rating,experience,newest',
            'per_page' => 'nullable|integer|min:1|max:30',
        ]);

        $query = Therapist::where('is_approved', true)
            ->with(['specializations', 'user'])
            ->withCount('reviews');

        if ($request->search) {
            $query->where(fn($q) =>
                $q->where('full_name', 'like', "%{$request->search}%")
                  ->orWhere('bio', 'like', "%{$request->search}%")
                  ->orWhere('title', 'like', "%{$request->search}%")
            );
        }

        if ($request->specialization_id) {
            $query->whereHas('specializations', fn($q) =>
                $q->where('specializations.id', $request->specialization_id)
            );
        }

        if ($request->city) {
            $query->where('city', 'like', "%{$request->city}%");
        }

        if ($request->gender) {
            $query->where('gender', $request->gender);
        }

        if ($request->type === 'online') {
            $query->where('accepts_online', true);
        } elseif ($request->type === 'in_person') {
            $query->where('accepts_in_person', true);
        }

        match ($request->sort ?? 'rating') {
            'rating' => $query->orderByDesc('rating_average')->orderByDesc('rating_count'),
            'experience' => $query->orderByDesc('years_experience'),
            'newest' => $query->orderByDesc('created_at'),
            default => $query->orderByDesc('rating_average'),
        };

        // Featured first
        $query->orderByDesc('is_featured');

        return response()->json($query->paginate($request->per_page ?? 15));
    }

    /** Approved colleagues for the logged-in therapist (excludes self). */
    public function colleagues(Request $request): JsonResponse
    {
        $me = $request->user()?->therapist;
        abort_if(!$me, 403);

        $request->validate([
            'search'   => 'nullable|string',
            'per_page' => 'nullable|integer|min:1|max:30',
        ]);

        $query = Therapist::where('is_approved', true)
            ->where('id', '!=', $me->id)
            ->with(['specializations', 'user'])
            ->orderBy('full_name');

        if ($request->search) {
            $query->where(fn($q) =>
                $q->where('full_name', 'like', "%{$request->search}%")
                  ->orWhere('title', 'like', "%{$request->search}%")
                  ->orWhere('city', 'like', "%{$request->search}%")
            );
        }

        return response()->json($query->paginate($request->per_page ?? 20));
    }

    public function show(Therapist $therapist): JsonResponse
    {
        abort_if(!$therapist->is_approved, 404);

        $therapist->load([
            'user:id,phone',
            'specializations', 'educations', 'certifications',
            'languages', 'clinics',
            'reels'    => fn($q) => $q->where('status', 'approved')->latest()->limit(10),
            'reviews'  => fn($q) => $q->where('is_visible', true)->with('patient')->latest()->limit(10),
        ]);

        // Rating distribution (1-5 stars)
        $ratingDist = \App\Models\Review::where('therapist_id', $therapist->id)
            ->where('is_visible', true)
            ->selectRaw('rating, COUNT(*) as count')
            ->groupBy('rating')
            ->pluck('count', 'rating');

        $distribution = [];
        for ($i = 5; $i >= 1; $i--) {
            $distribution[$i] = $ratingDist[$i] ?? 0;
        }

        // Monthly appointments (last 6 months)
        $monthly = \App\Models\Appointment::where('therapist_id', $therapist->id)
            ->where('status', 'completed')
            ->where('scheduled_at', '>=', now()->subMonths(6))
            ->selectRaw("DATE_FORMAT(scheduled_at, '%Y-%m') as month, COUNT(*) as count")
            ->groupBy('month')
            ->orderBy('month')
            ->pluck('count', 'month');

        $totalApts      = \App\Models\Appointment::where('therapist_id', $therapist->id)->count();
        $completedApts  = \App\Models\Appointment::where('therapist_id', $therapist->id)->where('status', 'completed')->count();
        $cancelledApts  = \App\Models\Appointment::where('therapist_id', $therapist->id)->where('status', 'cancelled')->count();
        $completionRate = $totalApts > 0 ? round(($completedApts / $totalApts) * 100) : 0;

        return response()->json([
            'therapist'   => $therapist,
            'stats' => [
                'total_sessions'       => $therapist->total_sessions,
                'total_patients'       => $therapist->total_patients,
                'rating_average'       => round($therapist->rating_average, 1),
                'rating_count'         => $therapist->rating_count,
                'years_experience'     => $therapist->years_experience,
                'total_appointments'   => $totalApts,
                'completed_appointments' => $completedApts,
                'cancelled_appointments' => $cancelledApts,
                'completion_rate'      => $completionRate,
                'rating_distribution'  => $distribution,
                'monthly_sessions'     => $monthly,
            ],
        ]);
    }

    /**
     * GET /therapists/nearby?lat=&lng=&radius=50
     * Returns approved therapists within radius (km), sorted by distance.
     *
     * A therapist's position is resolved in order of precision: their own
     * latitude/longitude, then a clinic's, then the centre of their city. Most
     * therapists never set explicit coordinates, and requiring them left the
     * map completely empty — the city fallback keeps them visible, flagged via
     * `location_precision` so the client can show it as approximate.
     */
    public function nearby(Request $request): JsonResponse
    {
        $request->validate([
            'lat'    => 'required|numeric|between:-90,90',
            'lng'    => 'required|numeric|between:-180,180',
            'radius' => 'nullable|numeric|min:1|max:200',
        ]);

        $lat    = (float) $request->lat;
        $lng    = (float) $request->lng;
        $radius = (float) ($request->radius ?? 50);

        $therapists = Therapist::where('is_approved', true)
            ->with(['specializations:id,name_ar,name_en', 'clinics:id,therapist_id,name,address,city,latitude,longitude'])
            ->get()
            ->map(function ($t) {
                [$tLat, $tLng, $precision] = $this->resolveLocation($t);
                if ($tLat === null || $tLng === null) {
                    return null;
                }

                return [
                    'therapist'  => $t,
                    'lat'        => $tLat,
                    'lng'        => $tLng,
                    'precision'  => $precision,
                ];
            })
            ->filter()
            ->map(function (array $row) use ($lat, $lng) {
                $row['distance'] = $this->haversineKm($lat, $lng, $row['lat'], $row['lng']);
                return $row;
            })
            ->filter(fn(array $row) => $row['distance'] <= $radius)
            ->sortBy('distance')
            ->take(50)
            ->map(function (array $row) {
                $t = $row['therapist'];

                return [
                    'id'                 => $t->id,
                    'full_name'          => $t->full_name,
                    'title'              => $t->title,
                    'avatar'             => $t->avatar,
                    'rating_average'     => $t->rating_average,
                    'rating_count'       => $t->rating_count,
                    'city'               => $t->city,
                    'latitude'           => $row['lat'],
                    'longitude'          => $row['lng'],
                    'distance_km'        => round($row['distance'], 1),
                    'location_precision' => $row['precision'], // exact | clinic | city
                    'accepts_online'     => (bool) $t->accepts_online,
                    'accepts_in_person'  => (bool) $t->accepts_in_person,
                    'specializations'    => $t->specializations->map(fn($s) => $s->name_ar)->toArray(),
                    'clinics'            => $t->clinics,
                ];
            })
            ->values();

        return response()->json($therapists);
    }

    /**
     * Best-known position for a therapist.
     *
     * @return array{0: float|null, 1: float|null, 2: string} [lat, lng, precision]
     */
    private function resolveLocation(Therapist $t): array
    {
        if ($t->latitude !== null && $t->longitude !== null) {
            return [(float) $t->latitude, (float) $t->longitude, 'exact'];
        }

        $clinic = $t->clinics->first(fn($c) => $c->latitude !== null && $c->longitude !== null);
        if ($clinic) {
            return [(float) $clinic->latitude, (float) $clinic->longitude, 'clinic'];
        }

        // Try the therapist's city, then any city recorded on their clinics.
        $candidates = array_filter(array_merge(
            [$t->city],
            $t->clinics->pluck('city')->all(),
            $t->clinics->pluck('address')->all(),
        ));

        foreach ($candidates as $candidate) {
            if ($coords = \App\Support\CityCoordinates::lookup($candidate)) {
                // Every therapist in one city would otherwise land on the exact
                // same pin, hiding all but one. Scatter them by a small amount
                // derived from the id so a given therapist stays put between
                // requests instead of jumping around the map.
                $offsetLat = ((($t->id * 37) % 100) - 50) / 100 * 0.02; // ±0.01°  (~1.1 km)
                $offsetLng = ((($t->id * 61) % 100) - 50) / 100 * 0.02;

                return [$coords['lat'] + $offsetLat, $coords['lng'] + $offsetLng, 'city'];
            }
        }

        return [null, null, 'unknown'];
    }

    /** Great-circle distance in kilometres. */
    private function haversineKm(float $lat1, float $lng1, float $lat2, float $lng2): float
    {
        $earthRadius = 6371.0;

        $dLat = deg2rad($lat2 - $lat1);
        $dLng = deg2rad($lng2 - $lng1);

        $a = sin($dLat / 2) ** 2
           + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * sin($dLng / 2) ** 2;

        return $earthRadius * 2 * atan2(sqrt($a), sqrt(1 - $a));
    }

    public function availableSlots(Request $request, Therapist $therapist): JsonResponse
    {
        $request->validate([
            'date' => 'required|date|after_or_equal:today',
            'type' => 'nullable|in:in_person,online',
        ]);

        abort_if(!$therapist->is_approved, 404);

        $slots = $this->appointmentService->getAvailableSlots(
            $therapist,
            $request->date,
            $request->type ?? 'in_person'
        );

        return response()->json(['slots' => $slots, 'date' => $request->date]);
    }

    public function book(Request $request, Therapist $therapist): JsonResponse
    {
        $request->validate([
            'date'          => 'required|date|after_or_equal:today',
            'time'          => 'required|date_format:H:i',
            'type'          => 'required|in:in_person,online',
            'clinic_id'     => 'nullable|exists:clinics,id',
            'patient_notes' => 'nullable|string|max:500',
            'is_for_other'  => 'nullable|boolean',
            'other_name'    => 'required_if:is_for_other,true|nullable|string|max:255',
            'other_age'     => 'nullable|integer|min:1|max:120',
            'other_relation'=> 'nullable|string|max:100',
        ]);

        abort_if(!$therapist->is_approved, 404);

        $scheduledAt = $request->date . ' ' . $request->time . ':00';

        // Verify slot is still available
        $slots = $this->appointmentService->getAvailableSlots($therapist, $request->date, $request->type);
        $slotAvailable = collect($slots)->firstWhere('time', $request->time);

        abort_if(!$slotAvailable, 422, 'هذا الوقت غير متاح');

        $appointment = $this->appointmentService->createAppointment([
            'therapist_id'  => $therapist->id,
            'patient_id'    => $request->user()->patient->id,
            'clinic_id'     => $request->clinic_id ?? $slotAvailable['clinic_id'],
            'scheduled_at'  => $scheduledAt,
            'type'          => $request->type,
            'patient_notes' => $request->patient_notes,
            'duration'      => $therapist->session_duration,
            'is_for_other'  => $request->boolean('is_for_other', false),
            'other_name'    => $request->other_name,
            'other_age'     => $request->other_age,
            'other_relation'=> $request->other_relation,
        ]);

        $patientName = $request->user()->patient->full_name;
        $this->fcmService->send(
            $therapist->user,
            'موعد جديد',
            "قام {$patientName} بحجز موعد جديد معك",
            ['appointment_id' => (string) $appointment->id],
            'new_appointment'
        );

        return response()->json(['appointment' => $appointment->load(['therapist', 'clinic'])], 201);
    }
}
