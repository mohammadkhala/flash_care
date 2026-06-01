<?php

namespace Database\Seeders;

use App\Models\Appointment;
use App\Models\Clinic;
use App\Models\Patient;
use App\Models\Therapist;
use App\Models\TherapistSchedule;
use App\Models\User;
use Illuminate\Database\Seeder;

class AppointmentSeeder extends Seeder
{
    public function run(): void
    {
        $patients = Patient::all();
        if ($patients->isEmpty()) {
            $patients = collect([$this->ensureDemoPatient()]);
        }

        $therapists = Therapist::where('is_approved', true)->get();
        if ($therapists->isEmpty()) {
            $therapists = Therapist::all();
        }

        if ($therapists->isEmpty()) {
            $this->command?->warn('لا يوجد أخصائيون في قاعدة البيانات.');

            return;
        }

        $createdSchedules = 0;
        $createdAppointments = 0;

        foreach ($therapists as $index => $therapist) {
            $clinic = $this->ensureClinic($therapist);
            $createdSchedules += $this->ensureSchedules($therapist, $clinic);
            $createdAppointments += $this->ensureAppointments($therapist, $clinic, $patients, $index);
        }

        $this->command?->info("تمت إضافة {$createdSchedules} جدول أسبوعي و {$createdAppointments} موعد.");
    }

    private function ensureDemoPatient(): Patient
    {
        $user = User::firstOrCreate(
            ['phone' => '599111111', 'phone_country_code' => '+970'],
            [
                'type' => 'patient',
                'is_active' => true,
                'phone_verified_at' => now(),
            ]
        );

        return Patient::firstOrCreate(
            ['user_id' => $user->id],
            [
                'full_name' => 'مريض تجريبي',
                'gender' => 'male',
                'city' => 'رام الله',
            ]
        );
    }

    private function ensureClinic(Therapist $therapist): Clinic
    {
        $existing = $therapist->clinics()->where('is_active', true)->first();
        if ($existing) {
            return $existing;
        }

        return Clinic::create([
            'therapist_id' => $therapist->id,
            'name' => 'عيادة ' . $therapist->full_name,
            'address' => 'شارع الرئيسي',
            'city' => $therapist->city ?? 'رام الله',
            'phone' => $therapist->user?->phone,
            'is_active' => true,
        ]);
    }

    private function ensureSchedules(Therapist $therapist, Clinic $clinic): int
    {
        if ($therapist->schedules()->where('is_active', true)->exists()) {
            return 0;
        }

        $slotDuration = $therapist->session_duration ?: 60;
        $workDays = [0, 1, 2, 3, 4]; // الأحد–الخميس
        $count = 0;

        $acceptsInPerson = $therapist->accepts_in_person ?? true;
        $acceptsOnline = $therapist->accepts_online ?? true;

        foreach ($workDays as $day) {
            if ($acceptsInPerson) {
                TherapistSchedule::create([
                    'therapist_id' => $therapist->id,
                    'clinic_id' => $clinic->id,
                    'type' => 'in_person',
                    'day_of_week' => $day,
                    'start_time' => '09:00',
                    'end_time' => '17:00',
                    'slot_duration' => $slotDuration,
                    'is_active' => true,
                ]);
                $count++;
            }

            if ($acceptsOnline) {
                TherapistSchedule::create([
                    'therapist_id' => $therapist->id,
                    'clinic_id' => null,
                    'type' => 'online',
                    'day_of_week' => $day,
                    'start_time' => '09:00',
                    'end_time' => '17:00',
                    'slot_duration' => $slotDuration,
                    'is_active' => true,
                ]);
                $count++;
            }
        }

        return $count;
    }

    private function ensureAppointments(Therapist $therapist, Clinic $clinic, $patients, int $therapistIndex): int
    {
        $duration = $therapist->session_duration ?: 60;
        $count = 0;

        $templates = [
            ['offset_days' => 1, 'hour' => 10, 'minute' => 0, 'status' => 'confirmed', 'type' => 'in_person'],
            ['offset_days' => 2, 'hour' => 11, 'minute' => 0, 'status' => 'confirmed', 'type' => 'online'],
            ['offset_days' => 3, 'hour' => 14, 'minute' => 0, 'status' => 'pending', 'type' => 'in_person'],
            ['offset_days' => 5, 'hour' => 15, 'minute' => 30, 'status' => 'pending', 'type' => 'online'],
            ['offset_days' => -5, 'hour' => 9, 'minute' => 0, 'status' => 'completed', 'type' => 'in_person'],
        ];

        foreach ($templates as $i => $template) {
            $patient = $patients[$($therapistIndex + $i) % $patients->count()];
            $scheduledAt = now()
                ->addDays($template['offset_days'])
                ->setTime($template['hour'], $template['minute'], 0);

            // تجنب التعارض: موعد واحد لكل أخصائي + مريض + وقت
            $exists = Appointment::where('therapist_id', $therapist->id)
                ->where('patient_id', $patient->id)
                ->where('scheduled_at', $scheduledAt)
                ->exists();

            if ($exists) {
                continue;
            }

            Appointment::create([
                'therapist_id' => $therapist->id,
                'patient_id' => $patient->id,
                'clinic_id' => $template['type'] === 'in_person' ? $clinic->id : null,
                'scheduled_at' => $scheduledAt,
                'duration' => $duration,
                'type' => $template['type'],
                'status' => $template['status'],
                'patient_notes' => 'موعد تجريبي من النظام',
            ]);
            $count++;
        }

        return $count;
    }
}
