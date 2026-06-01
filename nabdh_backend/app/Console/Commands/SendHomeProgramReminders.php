<?php

namespace App\Console\Commands;

use App\Models\HomeProgram;
use App\Services\FcmService;
use Illuminate\Console\Command;

class SendHomeProgramReminders extends Command
{
    protected $signature   = 'reminders:programs';
    protected $description = 'Send daily FCM reminders for active home programs';

    public function __construct(private FcmService $fcmService)
    {
        parent::__construct();
    }

    public function handle(): void
    {
        $today = now()->toDateString();

        // Active programs whose end_date hasn't passed (or has no end_date)
        $programs = HomeProgram::with(['patient.user'])
            ->where('is_active', true)
            ->where('start_date', '<=', $today)
            ->where(fn($q) => $q->whereNull('end_date')->orWhere('end_date', '>=', $today))
            ->get();

        // Group by patient to send one notification per patient
        $patientPrograms = $programs->groupBy('patient_id');

        foreach ($patientPrograms as $patientId => $patientProgramList) {
            $patient = $patientProgramList->first()->patient;
            if (!$patient?->user) continue;

            $count = $patientProgramList->count();
            $title = $count === 1
                ? "تذكير: برنامجك المنزلي اليومي 💪"
                : "تذكير: لديك {$count} برامج منزلية اليوم 💪";

            $firstName = explode(' ', $patient->full_name)[0];
            $body = "{$firstName}، لا تنسَ ممارسة تمارينك اليومية للحصول على أفضل النتائج!";

            $this->fcmService->send(
                $patient->user,
                $title,
                $body,
                ['type' => 'home_program_reminder'],
                'home_program_reminder'
            );
        }

        $this->info("Sent reminders to {$patientPrograms->count()} patients.");
    }
}
