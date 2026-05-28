<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Appointment;
use App\Models\Patient;
use App\Models\Reel;
use App\Models\Therapist;
use App\Models\User;
use App\Services\FcmService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    public function __construct(private FcmService $fcmService) {}

    public function dashboard(): JsonResponse
    {
        return response()->json([
            'statistics' => [
                'total_therapists' => Therapist::count(),
                'approved_therapists' => Therapist::where('is_approved', true)->count(),
                'pending_therapists' => Therapist::where('is_approved', false)->count(),
                'total_patients' => Patient::count(),
                'total_appointments' => Appointment::count(),
                'completed_appointments' => Appointment::where('status', 'completed')->count(),
                'pending_reels' => Reel::where('status', 'pending')->count(),
                'this_month_appointments' => Appointment::whereMonth('scheduled_at', now()->month)->count(),
            ],
            'monthly_chart' => Appointment::selectRaw('MONTH(scheduled_at) as month, COUNT(*) as count')
                ->whereYear('scheduled_at', now()->year)
                ->groupBy('month')
                ->orderBy('month')
                ->get(),
        ]);
    }

    // Therapist management
    public function pendingTherapists(): JsonResponse
    {
        $therapists = Therapist::where('is_approved', false)
            ->with(['user', 'specializations', 'educations', 'certifications', 'documents'])
            ->orderByDesc('created_at')
            ->paginate(15);

        return response()->json($therapists);
    }

    public function approveTherapist(Therapist $therapist): JsonResponse
    {
        $therapist->update(['is_approved' => true, 'approved_at' => now()]);

        $this->fcmService->send(
            $therapist->user,
            'تمت الموافقة على حسابك',
            'مرحباً بك في نبض! تم توثيق حسابك ويمكنك الآن استقبال المرضى.',
            [],
            'account_approved'
        );

        return response()->json(['message' => 'تمت الموافقة على الأخصائي']);
    }

    public function rejectTherapist(Request $request, Therapist $therapist): JsonResponse
    {
        $request->validate(['reason' => 'required|string']);

        $therapist->update(['is_approved' => false]);

        $this->fcmService->send(
            $therapist->user,
            'طلب التسجيل',
            "نأسف، لم يتم قبول طلبك. السبب: {$request->reason}",
            [],
            'account_rejected'
        );

        return response()->json(['message' => 'تم رفض الطلب']);
    }

    // Reels moderation
    public function pendingReels(): JsonResponse
    {
        $reels = Reel::where('status', 'pending')
            ->with('therapist')
            ->orderByDesc('created_at')
            ->paginate(15);

        return response()->json($reels);
    }

    public function approveReel(Reel $reel): JsonResponse
    {
        $reel->update(['status' => 'approved']);
        return response()->json(['message' => 'تم نشر الريل']);
    }

    public function rejectReel(Request $request, Reel $reel): JsonResponse
    {
        $request->validate(['reason' => 'required|string']);
        $reel->update(['status' => 'rejected', 'rejection_reason' => $request->reason]);
        return response()->json(['message' => 'تم رفض الريل']);
    }

    // Users management
    public function users(Request $request): JsonResponse
    {
        $query = User::with(['therapist', 'patient'])->orderByDesc('created_at');

        if ($request->type) $query->where('type', $request->type);
        if ($request->search) {
            $query->where('phone', 'like', "%{$request->search}%");
        }

        return response()->json($query->paginate(20));
    }

    public function toggleUserStatus(User $user): JsonResponse
    {
        $user->update(['is_active' => !$user->is_active]);
        return response()->json(['is_active' => $user->is_active]);
    }
}
