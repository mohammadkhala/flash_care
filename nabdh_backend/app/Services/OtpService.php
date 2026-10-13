<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class OtpService
{
    private ?string $lastError = null;

    public function getLastError(): ?string
    {
        return $this->lastError;
    }

    public function generateAndSend(User $user): bool
    {
        $otp = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        $user->update([
            'otp' => $otp,
            'otp_expires_at' => now()->addMinutes(10),
        ]);

        $local = User::normalizePhone($user->phone);
        if ($this->sendWhatsApp($user->phone_country_code . $local, $otp)) {
            return true;
        }

        // Palestinian numbers are often registered on WhatsApp under the other
        // code (+970 ↔ +972). WaSender allows one message per 5 s.
        if ($this->notOnWhatsApp && in_array($user->phone_country_code, User::SHARED_PLAN_CODES, true)) {
            $other = $user->phone_country_code === '+970' ? '+972' : '+970';
            sleep(5);
            return $this->sendWhatsApp($other . $local, $otp);
        }

        return false;
    }

    private bool $notOnWhatsApp = false;

    private function sendWhatsApp(string $phone, string $otp): bool
    {
        $this->lastError = null;
        $this->notOnWhatsApp = false;

        // E.164 format
        $phone = ltrim($phone, '+');
        $phone = '+' . $phone;

        $message = "مرحباً بك في نبض! 💙\n\nرمز التحقق الخاص بك:\n\n*{$otp}*\n\nصالح لمدة 10 دقائق.\nلا تشاركه مع أحد.";

        $apiKey = config('services.wasender.api_key');

        if (empty($apiKey)) {
            $this->lastError = 'WASENDER_API_KEY غير مضبوط في ملف .env';
            Log::warning("[OTP] {$this->lastError} — {$phone}");

            if (app()->environment('local')) {
                Log::info("[OTP] (local) {$phone} → {$otp}");
                return true;
            }

            return false;
        }

        try {
            $response = Http::timeout(30)->withHeaders([
                'Authorization' => 'Bearer ' . $apiKey,
                'Content-Type'  => 'application/json',
                'Accept'        => 'application/json',
            ])->post('https://www.wasenderapi.com/api/send-message', [
                'to'   => $phone,
                'text' => $message,
            ]);

            if ($response->successful() && $response->json('success')) {
                Log::info("[OTP] Sent to {$phone}, msgId=" . $response->json('data.msgId'));
                return true;
            }

            $this->lastError = "HTTP {$response->status()}: " . $response->body();
            $this->notOnWhatsApp = $response->status() === 422
                && str_contains((string) $response->json('message'), 'does not exist on WhatsApp');
            Log::error("[OTP] WaSender failed ({$phone}): " . $this->lastError);
            return false;

        } catch (\Exception $e) {
            $this->lastError = $e->getMessage();
            Log::error('[OTP] WaSender exception: ' . $this->lastError);
            return false;
        }
    }
}
