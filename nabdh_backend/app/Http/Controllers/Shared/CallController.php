<?php

namespace App\Http\Controllers\Shared;

use App\Http\Controllers\Controller;
use App\Models\Conversation;
use App\Models\User;
use App\Models\WebrtcSignal;
use App\Services\FcmService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CallController extends Controller
{
    public function __construct(private FcmService $fcmService) {}

    /**
     * Caller: create/replace signal + notify callee via FCM.
     */
    public function initiate(Request $request): JsonResponse
    {
        $request->validate([
            'conversation_id' => 'nullable|integer',
            'appointment_id'  => 'nullable|integer',
            'offer'           => 'required|string',
            'is_video'        => 'boolean',
        ]);

        $user = $request->user();

        if ($request->filled('appointment_id')) {
            $apt     = \App\Models\Appointment::findOrFail($request->appointment_id);
            $channel = 'webrtc-session-' . $apt->id;
            if ($user->isTherapist()) {
                $calleeId   = $apt->patient->user_id;
                $callerName = $user->therapist->full_name;
            } else {
                $calleeId   = $apt->therapist->user_id;
                $callerName = $user->patient->full_name;
            }
        } else {
            $conv    = Conversation::findOrFail($request->conversation_id);
            $channel = 'webrtc-conv-' . $request->conversation_id;
            if ($user->isTherapist()) {
                $calleeId   = $conv->patient->user_id;
                $callerName = $user->therapist->full_name;
            } else {
                $calleeId   = $conv->therapist->user_id;
                $callerName = $user->patient->full_name;
            }
        }

        $isVideo = $request->boolean('is_video', true);

        $signal = WebrtcSignal::updateOrCreate(
            ['channel' => $channel],
            [
                'caller_id'   => $user->id,
                'callee_id'   => $calleeId,
                'offer'       => $request->offer,
                'is_video'    => $isVideo,
                'caller_name' => $callerName,
                'status'      => 'ringing',
                'answer'      => null,
                'caller_ice'  => [],
                'callee_ice'  => [],
            ]
        );

        // Push FCM to callee
        $callee = User::findOrFail($calleeId);
        $this->fcmService->send(
            $callee,
            ($isVideo ? 'مكالمة فيديو' : 'مكالمة صوتية') . " من {$callerName}",
            'اضغط للرد على المكالمة',
            [
                'type'            => 'incoming_call',
                'channel'         => $channel,
                'caller_name'     => $callerName,
                'is_video'        => $isVideo ? 'true' : 'false',
                'conversation_id' => (string) $request->conversation_id,
            ],
            'incoming_call'
        );

        return response()->json($signal);
    }

    /**
     * Caller + callee: poll signal state.
     */
    public function show(string $channel): JsonResponse
    {
        $signal = WebrtcSignal::where('channel', $channel)->firstOrFail();
        return response()->json($signal);
    }

    /**
     * Callee: store SDP answer.
     */
    public function answer(Request $request, string $channel): JsonResponse
    {
        $request->validate(['answer' => 'required|string']);

        $signal = WebrtcSignal::where('channel', $channel)->firstOrFail();
        $signal->update(['answer' => $request->answer, 'status' => 'active']);

        return response()->json(['ok' => true]);
    }

    /**
     * Both sides: append an ICE candidate.
     */
    public function addIce(Request $request, string $channel): JsonResponse
    {
        $request->validate(['candidate' => 'required']);

        $signal    = WebrtcSignal::where('channel', $channel)->firstOrFail();
        $isCaller  = $request->user()->id === $signal->caller_id;
        $field     = $isCaller ? 'caller_ice' : 'callee_ice';
        $list      = $signal->$field ?? [];
        $list[]    = $request->candidate;
        $signal->update([$field => $list]);

        return response()->json(['ok' => true]);
    }

    /**
     * Both sides: end / reject / mark missed.
     */
    public function updateStatus(Request $request, string $channel): JsonResponse
    {
        $request->validate(['status' => 'required|in:ended,rejected,missed,active']);

        $signal = WebrtcSignal::where('channel', $channel)->firstOrFail();
        $signal->update(['status' => $request->status]);

        return response()->json(['ok' => true]);
    }
}
