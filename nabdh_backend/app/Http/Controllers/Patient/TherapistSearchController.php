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
     * Returns approved therapists within radius (km) with coordinates, sorted by distance.
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

        // Haversine formula via raw SQL
        $therapists = Therapist::where('is_approved', true)
            ->whereNotNull('latitude')
            ->whereNotNull('longitude')
            ->with(['specializations:id,name_ar,name_en', 'clinics:id,therapist_id,name,address,latitude,longitude'])
            ->selectRaw("
                therapists.*,
                ( 6371 * acos(
                    cos(radians(?)) * cos(radians(latitude))
                    * cos(radians(longitude) - radians(?))
                    + sin(radians(?)) * sin(radians(latitude))
                )) AS distance_km
            ", [$lat, $lng, $lat])
            ->having('distance_km', '<=', $radius)
            ->orderBy('distance_km')
            ->limit(50)
            ->get()
            ->map(fn($t) => [
                'id'             => $t->id,
                'full_name'      => $t->full_name,
                'title'          => $t->title,
                'avatar'         => $t->avatar,
                'rating_average' => $t->rating_average,
                'rating_count'   => $t->rating_count,
                'city'           => $t->city,
                'latitude'       => (float) $t->latitude,
                'longitude'      => (float) $t->longitude,
                'distance_km'    => round($t->distance_km, 1),
                'accepts_online' => (bool) $t->accepts_online,
                'accepts_in_person' => (bool) $t->accepts_in_person,
                'specializations'   => $t->specializations->map(fn($s) => $s->name_ar)->toArray(),
                'clinics'           => $t->clinics,
            ]);

        return response()->json($therapists);
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
