<?php

namespace App\Http\Controllers\Shared;

use App\Http\Controllers\Controller;
use App\Models\Conversation;
use App\Models\User;
use App\Models\WebrtcSignal;
use App\Services\CallChannel;
use App\Services\FcmService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

/**
 * Call state for Agora calls. Media goes through Agora; this controller only
 * tracks ringing / active / ended and pushes the ring to the callee.
 * (Table name `webrtc_signals` is historical.)
 */
class CallController extends Controller
{
    public function __construct(private FcmService $fcmService) {}

    /**
     * Caller: create the call and ring the callee via data-only FCM.
     */
    public function initiate(Request $request): JsonResponse
    {
        $request->validate([
            'conversation_id' => 'nullable|integer',
            'appointment_id'  => 'nullable|integer',
            'is_video'        => 'boolean',
        ]);

        $user = $request->user();

        if ($request->filled('appointment_id')) {
            $apt     = \App\Models\Appointment::with(['patient', 'therapist'])->findOrFail($request->appointment_id);
            $channel = CallChannel::forAppointment($apt->id);
            if ($user->isTherapist()) {
                $calleeId   = $apt->patient->user_id;
                $callerName = $user->therapist->full_name;
            } else {
                $calleeId   = $apt->therapist->user_id;
                $callerName = $user->patient->full_name;
            }
        } else {
            $conv    = Conversation::with(['patient', 'therapist', 'peerTherapist'])->findOrFail($request->conversation_id);
            $channel = CallChannel::forConversation($conv->id);
            if ($conv->isTherapistPair()) {
                abort_if(!$user->isTherapist(), 403);
                $other = $conv->otherTherapist($user->therapist->id);
                abort_if(!$other, 422);
                $calleeId   = $other->user_id;
                $callerName = $user->therapist->full_name;
            } elseif ($user->isTherapist()) {
                $calleeId   = $conv->patient->user_id;
                $callerName = $user->therapist->full_name;
            } else {
                $calleeId   = $conv->therapist->user_id;
                $callerName = $user->patient->full_name;
            }
        }

        abort_unless(CallChannel::allows($channel, $user->id), 403);

        $isVideo = $request->boolean('is_video', true);

        $signal = WebrtcSignal::updateOrCreate(
            ['channel' => $channel],
            [
                'caller_id'   => $user->id,
                'callee_id'   => $calleeId,
                'offer'       => null,
                'answer'      => null,
                'is_video'    => $isVideo,
                'caller_name' => $callerName,
                'status'      => 'ringing',
                'caller_ice'  => [],
                'callee_ice'  => [],
            ]
        );

        $this->fcmService->sendCall(User::findOrFail($calleeId), [
            'type'            => 'incoming_call',
            'call_id'         => (string) Str::uuid(),
            'channel'         => $channel,
            'caller_name'     => $callerName,
            'is_video'        => $isVideo ? 'true' : 'false',
            'conversation_id' => (string) $request->input('conversation_id', ''),
            'appointment_id'  => (string) $request->input('appointment_id', ''),
        ]);

        return response()->json($signal);
    }

    /**
     * Caller + callee: poll call state.
     */
    public function show(Request $request, string $channel): JsonResponse
    {
        $signal = $this->signalFor($request, $channel);
        return response()->json($signal);
    }

    /**
     * Callee: accepted the call.
     */
    public function answer(Request $request, string $channel): JsonResponse
    {
        $signal = WebrtcSignal::where('channel', $channel)->first();

        // Joining an appointment session before the therapist started it is fine.
        if (!$signal) {
            abort_unless(CallChannel::allows($channel, $request->user()->id), 403);
            return response()->json(['ok' => true]);
        }

        $this->authorizeParty($request, $signal);
        if ($signal->status === 'ringing') {
            $signal->update(['status' => 'active']);
        }

        return response()->json(['ok' => true]);
    }

    /**
     * Both sides: end / reject / mark missed. Stops the ring on the other phone.
     */
    public function updateStatus(Request $request, string $channel): JsonResponse
    {
        $request->validate(['status' => 'required|in:ended,rejected,missed,active']);

        $signal = $this->signalFor($request, $channel);
        $status = $request->status;
        $wasLive = in_array($signal->status, ['ringing', 'active'], true);

        $signal->update(['status' => $status]);

        if ($wasLive && $status !== 'active') {
            $otherId = (int) $request->user()->id === (int) $signal->caller_id
                ? $signal->callee_id
                : $signal->caller_id;
            $other = User::find($otherId);

            if ($other) {
                $this->fcmService->sendCall($other, [
                    'type'    => 'call_ended',
                    'channel' => $channel,
                    'status'  => $status,
                ]);

                if ($status === 'missed' && (int) $otherId === (int) $signal->callee_id) {
                    $this->notifyMissed($other, $signal);
                }
            }
        }

        return response()->json(['ok' => true]);
    }

    private function notifyMissed(User $callee, WebrtcSignal $signal): void
    {
        $data = ['type' => 'missed_call', 'channel' => $signal->channel];
        if (preg_match('/^nabd-conv-(\d+)$/', $signal->channel, $m)) {
            $data['conversation_id'] = $m[1];
        } elseif (preg_match('/^nabd-session-(\d+)$/', $signal->channel, $m)) {
            $data['appointment_id'] = $m[1];
        }

        $this->fcmService->send(
            $callee,
            ($signal->is_video ? 'مكالمة فيديو فائتة' : 'مكالمة فائتة') . " من {$signal->caller_name}",
            'اضغط لفتح المحادثة',
            $data,
            'missed_call'
        );
    }

    private function signalFor(Request $request, string $channel): WebrtcSignal
    {
        $signal = WebrtcSignal::where('channel', $channel)->firstOrFail();
        $this->authorizeParty($request, $signal);
        return $signal;
    }

    private function authorizeParty(Request $request, WebrtcSignal $signal): void
    {
        $uid = (int) $request->user()->id;
        abort_unless(in_array($uid, [(int) $signal->caller_id, (int) $signal->callee_id], true), 403);
    }
}
