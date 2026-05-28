<?php

namespace App\Console\Commands;

use App\Services\OtpService;
use App\Models\User;
use Illuminate\Console\Command;

class TestOtp extends Command
{
    protected $signature   = 'nabdh:test-otp {phone} {--code=+970}';
    protected $description = 'اختبار إرسال OTP عبر WaSender';

    public function handle(OtpService $otpService): void
    {
        $phone = $this->argument('phone');
        $code  = $this->option('code');

        $user = User::firstOrCreate(
            ['phone' => $phone, 'phone_country_code' => $code],
            ['type' => 'patient', 'is_active' => true]
        );

        $this->info("إرسال OTP إلى: {$code}{$phone}");

        $sent = $otpService->generateAndSend($user);

        if ($sent) {
            $this->info('✅ تم الإرسال بنجاح عبر WaSender');
            $this->line("OTP: {$user->fresh()->otp}");
        } else {
            $this->error('❌ فشل الإرسال - راجع اللوج');
        }
    }
}
