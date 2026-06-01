<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// ─── Scheduled reminders ──────────────────────────────────────────────────────
// Run: * * * * * php /path/to/artisan schedule:run >> /dev/null 2>&1

// Send appointment reminders every 30 minutes (checks 24h and 1h windows)
Schedule::command('reminders:sessions')->everyThirtyMinutes();

// Send home program reminders daily at 8:00 AM
Schedule::command('reminders:programs')->dailyAt('08:00');
