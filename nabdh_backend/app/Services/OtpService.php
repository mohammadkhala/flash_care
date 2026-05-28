<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class OtpService
{
    public function generateAndSend(User $user): bool
    {
        $otp = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        $user->update([
            'otp' => $otp,
            'otp_expires_at' => now()->addMinutes(10),
        ]);

        return $this->sendWhatsApp($user->phone_country_code . $user->phone, $otp);
    }

    private function sendWhatsApp(string $phone, string $otp): bool
    {
        // Normalize phone: remove leading + for WaSender if needed, keep E.164 format
        $phone = ltrim($phone, '+');
        $phone = '+' . $phone; // ensure + prefix

        $message = "مرحباً بك في نبض! 💙\n\nرمز التحقق الخاص بك:\n\n*{$otp}*\n\nصالح لمدة 10 دقائق.\nلا تشاركه مع أحد.";

        // In development with no API key configured, just log
        if (!config('services.wasender.api_key')) {
            Log::info("[OTP] {$phone} → {$otp}");
            return true;
        }

        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . config('services.wasender.api_key'),
                'Content-Type'  => 'application/json',
            ])->post('https://www.wasenderapi.com/api/send-message', [
                'to'   => $phone,
                'text' => $message,
            ]);

            if ($response->successful() && $response->json('success')) {
                Log::info("[OTP] Sent to {$phone}, msgId=" . $response->json('data.msgId'));
                return true;
            }

            Log::error('[OTP] WaSender failed: ' . $response->body());
            return false;

        } catch (\Exception $e) {
            Log::error('[OTP] WaSender exception: ' . $e->getMessage());
            return false;
        }
    }
}
