<?php

namespace App\Services;

use App\Models\PushNotification;
use App\Models\User;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;

class FcmService
{
    public function send(User $user, string $title, string $body, array $data = [], string $type = 'general'): void
    {
        // Always store in DB so in-app polling works
        PushNotification::create([
            'user_id' => $user->id,
            'title'   => $title,
            'body'    => $body,
            'type'    => $type,
            'data'    => $data,
        ]);

        if (!$user->fcm_token) return;

        $this->sendPush($user->fcm_token, $title, $body, array_merge($data, ['type' => $type]));
    }

    public function sendToMany(array $userIds, string $title, string $body, array $data = [], string $type = 'general'): void
    {
        $users = User::whereIn('id', $userIds)->get();
        foreach ($users as $user) {
            $this->send($user, $title, $body, $data, $type);
        }
    }

    /**
     * Send directly to a list of FCM tokens (no DB record — for admin mass-push).
     */
    public function sendToMultiple(array $tokens, string $title, string $body, array $data = []): void
    {
        foreach ($tokens as $token) {
            try { $this->sendPush($token, $title, $body, $data); } catch (\Exception) {}
        }
    }

    // ── FCM v1 API ────────────────────────────────────────────────────────────

    private function sendPush(string $token, string $title, string $body, array $data): void
    {
        $projectId = config('services.firebase.project_id');
        $credPath  = config('services.firebase.credentials');

        if (empty($projectId) || empty($credPath)) {
            Log::warning('FCM not configured (FIREBASE_PROJECT_ID or FIREBASE_CREDENTIALS missing)');
            return;
        }

        try {
            $accessToken = $this->getAccessToken($credPath);

            $message = [
                'message' => [
                    'token'        => $token,
                    'notification' => ['title' => $title, 'body' => $body],
                    'data'         => array_map('strval', $data),
                    'android'      => [
                        'priority'     => 'high',
                        'notification' => ['sound' => 'default'],
                    ],
                    'apns' => [
                        'headers' => ['apns-priority' => '10'],
                        'payload' => ['aps' => ['sound' => 'default']],
                    ],
                ],
            ];

            $client = new \GuzzleHttp\Client(['timeout' => 10]);
            $client->post(
                "https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send",
                [
                    'headers' => [
                        'Authorization' => 'Bearer ' . $accessToken,
                        'Content-Type'  => 'application/json',
                    ],
                    'json' => $message,
                ]
            );
        } catch (\Exception $e) {
            Log::error('FCM push failed: ' . $e->getMessage());
        }
    }

    /**
     * Get OAuth2 access token from service account JSON.
     * Cached for 55 minutes (tokens expire in 60).
     */
    private function getAccessToken(string $credPath): string
    {
        return Cache::remember('fcm_access_token', 55 * 60, function () use ($credPath) {
            $fullPath = base_path($credPath);

            if (!file_exists($fullPath)) {
                throw new \RuntimeException("Firebase credentials file not found: {$fullPath}");
            }

            $creds = json_decode(file_get_contents($fullPath), true);

            $now    = time();
            $header = base64_encode(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));
            $claim  = base64_encode(json_encode([
                'iss'   => $creds['client_email'],
                'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
                'aud'   => 'https://oauth2.googleapis.com/token',
                'iat'   => $now,
                'exp'   => $now + 3600,
            ]));

            $header = str_replace(['+', '/', '='], ['-', '_', ''], $header);
            $claim  = str_replace(['+', '/', '='], ['-', '_', ''], $claim);

            $toSign = "{$header}.{$claim}";

            openssl_sign($toSign, $signature, $creds['private_key'], 'SHA256');
            $sig = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));

            $jwt = "{$toSign}.{$sig}";

            $client   = new \GuzzleHttp\Client(['timeout' => 10]);
            $response = $client->post('https://oauth2.googleapis.com/token', [
                'form_params' => [
                    'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                    'assertion'  => $jwt,
                ],
            ]);

            $result = json_decode($response->getBody()->getContents(), true);
            return $result['access_token'];
        });
    }
}
