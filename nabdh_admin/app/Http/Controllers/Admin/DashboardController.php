<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Appointment;
use App\Models\Patient;
use App\Models\Reel;
use App\Models\Therapist;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function index()
    {
        $stats = [
            'total_therapists'       => Therapist::count(),
            'approved_therapists'    => Therapist::where('is_approved', true)->count(),
            'pending_therapists'     => Therapist::where('is_approved', false)->count(),
            'total_patients'         => Patient::count(),
            'total_appointments'     => Appointment::count(),
            'completed_appointments' => Appointment::where('status', 'completed')->count(),
            'this_month'             => Appointment::whereMonth('scheduled_at', now()->month)->count(),
            'pending_reels'          => Reel::where('status', 'pending')->count(),
            'new_users_today'        => User::whereDate('created_at', today())->count(),
        ];

        $monthlyData = Appointment::selectRaw('MONTH(scheduled_at) as month, COUNT(*) as total')
            ->whereYear('scheduled_at', now()->year)
            ->groupBy('month')
            ->orderBy('month')
            ->pluck('total', 'month')
            ->toArray();

        // Fill missing months with 0
        $chart = [];
        $months = ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
        for ($m = 1; $m <= 12; $m++) {
            $chart[] = ['month' => $months[$m - 1], 'total' => $monthlyData[$m] ?? 0];
        }

        $recentTherapists = Therapist::with('user')
            ->where('is_approved', false)
            ->latest()
            ->limit(5)
            ->get();

        return view('admin.dashboard', compact('stats', 'chart', 'recentTherapists'));
    }
}
