<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Appointment;
use Illuminate\Http\Request;

class AppointmentController extends Controller
{
    public function index(Request $request)
    {
        $query = Appointment::with(['therapist', 'patient'])
            ->latest('scheduled_at');

        if ($request->status) $query->where('status', $request->status);
        if ($request->type)   $query->where('type', $request->type);
        if ($request->date)   $query->whereDate('scheduled_at', $request->date);

        if ($request->search) {
            $query->whereHas('therapist', fn($q) => $q->where('full_name', 'like', "%{$request->search}%"))
                ->orWhereHas('patient', fn($q) => $q->where('full_name', 'like', "%{$request->search}%"));
        }

        $appointments = $query->paginate(20)->withQueryString();

        $summary = [
            'total'     => Appointment::count(),
            'pending'   => Appointment::where('status', 'pending')->count(),
            'confirmed' => Appointment::where('status', 'confirmed')->count(),
            'completed' => Appointment::where('status', 'completed')->count(),
        ];

        return view('admin.appointments.index', compact('appointments', 'summary'));
    }
}
