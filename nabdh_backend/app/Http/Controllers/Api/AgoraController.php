<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\Agora\AccessToken2;
use App\Services\Agora\ServiceRtc;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AgoraController extends Controller
{
    /**
     * POST /api/agora/token
     *
     * Body: { "channel": "nabdh-chat-42", "uid": 0 }
     * Returns: { "token": "007...", "uid": 0, "channel": "...", "expires_in": 3600 }
     */
    public function token(Request $request): JsonResponse
    {
        $request->validate([
            'channel' => ['required', 'string', 'max:64'],
            'uid'     => ['nullable', 'integer', 'min:0'],
        ]);

        $appId   = config('services.agora.app_id');
        $appCert = config('services.agora.app_certificate');

        // If Agora credentials are not configured, return a guest token placeholder
        // so the app can still run in development without a token.
        if (empty($appId) || empty($appCert)) {
            return response()->json([
                'token'      => null,   // Agora test mode: pass null / empty token
                'uid'        => $request->integer('uid', 0),
                'channel'    => $request->input('channel'),
                'expires_in' => 3600,
                'note'       => 'Agora credentials not configured — using no-token mode',
            ]);
        }

        $channel    = $request->input('channel');
        $uid        = $request->integer('uid', 0);
        $expiresSec = 3600; // 1 hour

        $token = new AccessToken2($appId, $appCert, $expiresSec);

        $svc = new ServiceRtc($channel, $uid);
        $svc->addPrivilege(ServiceRtc::PRIV_JOIN_CHANNEL,          time() + $expiresSec);
        $svc->addPrivilege(ServiceRtc::PRIV_PUBLISH_AUDIO_STREAM,  time() + $expiresSec);
        $svc->addPrivilege(ServiceRtc::PRIV_PUBLISH_VIDEO_STREAM,  time() + $expiresSec);
        $svc->addPrivilege(ServiceRtc::PRIV_SUBSCRIBE_AUDIO_STREAM, time() + $expiresSec);
        $svc->addPrivilege(ServiceRtc::PRIV_SUBSCRIBE_VIDEO_STREAM, time() + $expiresSec);
        $token->addService($svc);

        return response()->json([
            'token'      => $token->build(),
            'uid'        => $uid,
            'channel'    => $channel,
            'expires_in' => $expiresSec,
        ]);
    }
}
