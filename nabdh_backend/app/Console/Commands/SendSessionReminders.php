<?php

namespace App\Console\Commands;

use App\Models\Appointment;
use App\Services\FcmService;
use Illuminate\Console\Command;
use Illuminate\Support\Carbon;

class SendSessionReminders extends Command
{
    protected $signature   = 'reminders:sessions';
    protected $description = 'Send FCM reminders for upcoming confirmed appointments (24h and 1h before)';

    public function __construct(private FcmService $fcmService)
    {
        parent::__construct();
    }

    public function handle(): void
    {
        $now = Carbon::now();

        // Windows to check: 24h ± 15min and 1h ± 15min
        $windows = [
            ['label' => '24 ساعة', 'from' => $now->copy()->addHours(23)->addMinutes(45), 'to' => $now->copy()->addHours(24)->addMinutes(15)],
            ['label' => 'ساعة',    'from' => $now->copy()->addMinutes(45),               'to' => $now->copy()->addMinutes(75)],
        ];

        foreach ($windows as $window) {
            $appointments = Appointment::with(['therapist.user', 'patient.user'])
                ->where('status', 'confirmed')
                ->whereBetween('scheduled_at', [$window['from'], $window['to']])
                ->get();

            foreach ($appointments as $appt) {
                $scheduledAt = Carbon::parse($appt->scheduled_at)->format('H:i');
                $typeLabel   = $appt->type === 'online' ? 'أونلاين' : 'حضوري';
                $timeLabel   = $window['label'];

                // Notify patient
                if ($appt->patient?->user) {
                    $this->fcmService->send(
                        $appt->patient->user,
                        "تذكير: موعدك خلال {$timeLabel} ⏰",
                        "موعدك مع {$appt->therapist?->full_name} الساعة {$scheduledAt} ({$typeLabel})",
                        ['appointment_id' => (string) $appt->id, 'type' => 'appointment_reminder'],
                        'appointment_reminder'
                    );
                }

                // Notify therapist
                if ($appt->therapist?->user) {
                    $this->fcmService->send(
                        $appt->therapist->user,
                        "تذكير: جلسة خلال {$timeLabel} ⏰",
                        "جلسة مع {$appt->patient?->full_name} الساعة {$scheduledAt} ({$typeLabel})",
                        ['appointment_id' => (string) $appt->id, 'type' => 'appointment_reminder'],
                        'appointment_reminder'
                    );
                }
            }

            $this->info("Processed {$appointments->count()} appointments for window: {$window['label']}");
        }
    }
}
