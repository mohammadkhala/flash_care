<?php

namespace App\Http\Controllers\Therapist;

use App\Http\Controllers\Controller;
use App\Models\TherapistCertification;
use App\Models\TherapistEducation;
use App\Models\TherapistLanguage;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ProfileController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $therapist = $request->user()->therapist->load([
            'specializations', 'educations', 'certifications',
            'languages', 'clinics', 'documents',
        ]);
        return response()->json(['therapist' => $therapist]);
    }

    public function update(Request $request): JsonResponse
    {
        $request->validate([
            'full_name' => 'sometimes|string|max:100',
            'full_name_en' => 'nullable|string|max:100',
            'title' => 'nullable|string|max:100',
            'bio' => 'nullable|string|max:2000',
            'bio_en' => 'nullable|string|max:2000',
            'years_experience' => 'sometimes|integer|min:0',
            'city' => 'nullable|string',
            'gender' => 'sometimes|in:male,female',
            'accepts_online' => 'boolean',
            'accepts_in_person' => 'boolean',
            'online_session_price' => 'nullable|numeric|min:0',
            'in_person_session_price' => 'nullable|numeric|min:0',
            'session_duration' => 'integer|in:30,45,60,90',
            'specialization_ids' => 'sometimes|array',
            'specialization_ids.*' => 'exists:specializations,id',
        ]);

        $therapist = $request->user()->therapist;
        $therapist->update($request->except('specialization_ids', 'avatar'));

        if ($request->has('specialization_ids')) {
            $therapist->specializations()->sync($request->specialization_ids);
        }

        return response()->json(['therapist' => $therapist->load('specializations')]);
    }

    public function uploadAvatar(Request $request): JsonResponse
    {
        $request->validate(['avatar' => 'required|image|max:5120']);

        $path = $request->file('avatar')->store('avatars/therapists', 'public');

        // If therapist profile already exists, update avatar immediately
        $therapist = $request->user()->therapist;
        if ($therapist) {
            if ($therapist->avatar) {
                Storage::disk('public')->delete($therapist->avatar);
            }
            $therapist->update(['avatar' => $path]);
        }

        return response()->json([
            'avatar_path' => $path,
            'avatar_url'  => Storage::disk('public')->url($path),
        ]);
    }

    public function addEducation(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'degree' => 'required|string',
            'institution' => 'required|string',
            'field_of_study' => 'nullable|string',
            'graduation_year' => 'nullable|digits:4',
        ]);

        $education = $request->user()->therapist->educations()->create($validated);
        return response()->json(['education' => $education], 201);
    }

    public function addCertification(Request $request): JsonResponse
    {
        $request->validate([
            'name' => 'required|string',
            'issuing_organization' => 'nullable|string',
            'issue_date' => 'nullable|date',
            'expiry_date' => 'nullable|date|after:issue_date',
            'file' => 'nullable|file|max:10240',
        ]);

        $data = $request->except('file');
        if ($request->hasFile('file')) {
            $data['file'] = $request->file('file')->store('certifications', 'public');
        }

        $cert = $request->user()->therapist->certifications()->create($data);
        return response()->json(['certification' => $cert], 201);
    }

    public function addLanguage(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'language' => 'required|string',
            'proficiency' => 'required|in:basic,conversational,fluent,native',
        ]);

        $lang = $request->user()->therapist->languages()->create($validated);
        return response()->json(['language' => $lang], 201);
    }

    public function statistics(Request $request): JsonResponse
    {
        $therapist = $request->user()->therapist;

        // Count unread chat messages (therapist_unread from conversations)
        $unread = \App\Models\Conversation::where('therapist_id', $therapist->id)
            ->sum('therapist_unread');

        $total      = $therapist->appointments()->count();
        $completed  = $therapist->appointments()->where('status', 'completed')->count();
        $cancelled  = $therapist->appointments()->where('status', 'cancelled')->count();
        $pending    = $therapist->appointments()->where('status', 'pending')->count();
        $confirmed  = $therapist->appointments()->where('status', 'confirmed')->count();

        $stats = [
            'total_appointments'     => $total,
            'completed_appointments' => $completed,
            'pending_appointments'   => $pending,
            'cancelled_appointments' => $cancelled,
            'confirmed_appointments' => $confirmed,
            'today_appointments'     => $therapist->appointments()->whereDate('scheduled_at', today())->count(),
            'total_patients'         => $therapist->appointments()->distinct('patient_id')->count('patient_id'),
            'completion_rate'        => $total > 0 ? round(($completed / $total) * 100) : 0,
            'rating_average'         => round((float)($therapist->rating_average ?? 0), 1),
            'rating_count'           => $therapist->rating_count ?? 0,
            'rating_distribution'    => $this->ratingDistribution($therapist),
            'unread_messages'        => $unread,
            'this_month_appointments'=> $therapist->appointments()
                ->whereMonth('scheduled_at', now()->month)
                ->whereYear('scheduled_at', now()->year)
                ->count(),
            'last_month_appointments'=> $therapist->appointments()
                ->whereMonth('scheduled_at', now()->subMonth()->month)
                ->whereYear('scheduled_at', now()->subMonth()->year)
                ->count(),
            'monthly_chart'          => $this->monthlyChart($therapist),
            'weekly_chart'           => $this->weeklyChart($therapist),
            'status_breakdown'       => [
                ['status' => 'completed',  'label' => 'مكتملة',    'count' => $completed,  'color' => '4CAF50'],
                ['status' => 'confirmed',  'label' => 'مؤكدة',     'count' => $confirmed,  'color' => '1B5E7B'],
                ['status' => 'pending',    'label' => 'انتظار',    'count' => $pending,    'color' => 'FF9800'],
                ['status' => 'cancelled',  'label' => 'ملغاة',     'count' => $cancelled,  'color' => 'E53935'],
            ],
        ];

        return response()->json(['statistics' => $stats]);
    }

    private function monthlyChart($therapist): array
    {
        return $therapist->appointments()
            ->selectRaw('MONTH(scheduled_at) as month, YEAR(scheduled_at) as year, COUNT(*) as count')
            ->where('scheduled_at', '>=', now()->subMonths(6))
            ->where('status', 'completed')
            ->groupBy('year', 'month')
            ->orderBy('year')->orderBy('month')
            ->get()
            ->toArray();
    }

    private function weeklyChart($therapist): array
    {
        $weeks = [];
        for ($i = 3; $i >= 0; $i--) {
            $start = now()->startOfWeek()->subWeeks($i);
            $end   = (clone $start)->endOfWeek();
            $weeks[] = [
                'week'  => $i === 0 ? 'هذا الأسبوع' : ($i === 1 ? 'الأسبوع الماضي' : "قبل $i أسابيع"),
                'count' => $therapist->appointments()
                    ->whereBetween('scheduled_at', [$start, $end])
                    ->where('status', 'completed')
                    ->count(),
            ];
        }
        return $weeks;
    }

    private function ratingDistribution($therapist): array
    {
        $dist = [];
        $total = $therapist->rating_count ?? 0;
        for ($star = 5; $star >= 1; $star--) {
            $count = $therapist->reviews()->where('rating', $star)->count();
            $dist[] = [
                'star'       => $star,
                'count'      => $count,
                'percentage' => $total > 0 ? round(($count / $total) * 100) : 0,
            ];
        }
        return $dist;
    }

    private function complianceOverview($therapist): array
    {
        $programs = $therapist->homePrograms()->where('is_active', true)->with('exercises.completions')->get();
        if ($programs->isEmpty()) return [];

        return $programs->map(fn($p) => [
            'program_id' => $p->id,
            'program_title' => $p->title,
            'patient_name' => $p->patient->full_name,
            'compliance_rate' => $p->complianceRate(),
        ])->toArray();
    }
}
