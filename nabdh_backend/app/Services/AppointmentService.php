<?php

namespace App\Services;

use App\Models\Appointment;
use App\Models\Therapist;
use App\Models\TherapistSchedule;
use App\Models\TherapistUnavailability;
use Carbon\Carbon;
use Carbon\CarbonPeriod;

class AppointmentService
{
    public function getAvailableSlots(Therapist $therapist, string $date, string $type = 'in_person'): array
    {
        $carbon = Carbon::parse($date);
        $dayOfWeek = $carbon->dayOfWeek;

        $schedules = TherapistSchedule::where('therapist_id', $therapist->id)
            ->where('day_of_week', $dayOfWeek)
            ->where('type', $type)
            ->where('is_active', true)
            ->get();

        if ($schedules->isEmpty()) return [];

        // Get booked appointments for the day
        $bookedTimes = Appointment::where('therapist_id', $therapist->id)
            ->whereDate('scheduled_at', $carbon)
            ->whereNotIn('status', ['cancelled_by_patient', 'cancelled_by_therapist'])
            ->pluck('scheduled_at')
            ->map(fn($dt) => Carbon::parse($dt)->format('H:i'))
            ->toArray();

        // Get unavailabilities
        $unavailabilities = TherapistUnavailability::where('therapist_id', $therapist->id)
            ->where('date', $carbon->toDateString())
            ->get();

        $slots = [];

        foreach ($schedules as $schedule) {
            $start = Carbon::parse($date . ' ' . $schedule->start_time);
            $end = Carbon::parse($date . ' ' . $schedule->end_time);

            while ($start->copy()->addMinutes($schedule->slot_duration)->lte($end)) {
                $slotTime = $start->format('H:i');
                $slotEnd = $start->copy()->addMinutes($schedule->slot_duration)->format('H:i');

                $isBooked = in_array($slotTime, $bookedTimes);
                $isUnavailable = $this->isSlotUnavailable($unavailabilities, $slotTime);
                $isPast = $start->isPast();

                if (!$isBooked && !$isUnavailable && !$isPast) {
                    $slots[] = [
                        'time' => $slotTime,
                        'time_end' => $slotEnd,
                        'clinic_id' => $schedule->clinic_id,
                        'available' => true,
                    ];
                }

                $start->addMinutes($schedule->slot_duration);
            }
        }

        return $slots;
    }

    private function isSlotUnavailable($unavailabilities, string $time): bool
    {
        foreach ($unavailabilities as $u) {
            if (!$u->start_time) return true; // full day
            if ($time >= $u->start_time && $time < $u->end_time) return true;
        }
        return false;
    }

    public function createAppointment(array $data): Appointment
    {
        $appointment = Appointment::create($data);

        app(FcmService::class)->send(
            $appointment->therapist->user,
            'موعد جديد',
            "لديك طلب موعد جديد من {$appointment->patient->full_name}",
            ['appointment_id' => (string) $appointment->id],
            'new_appointment'
        );

        return $appointment;
    }

    public function confirmAppointment(Appointment $appointment): void
    {
        $appointment->update(['status' => 'confirmed']);

        app(FcmService::class)->send(
            $appointment->patient->user,
            'تم تأكيد موعدك',
            "تم تأكيد موعدك مع {$appointment->therapist->full_name}",
            ['appointment_id' => (string) $appointment->id],
            'appointment_confirmed'
        );
    }
}
