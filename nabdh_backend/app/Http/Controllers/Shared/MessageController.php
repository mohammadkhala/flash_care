<?php

namespace App\Http\Controllers\Shared;

use App\Http\Controllers\Controller;
use App\Models\Conversation;
use App\Models\Message;
use App\Models\Therapist;
use App\Services\FcmService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class MessageController extends Controller
{
    public function __construct(private FcmService $fcmService) {}

    public function conversations(Request $request): JsonResponse
    {
        $user = $request->user();

        if ($user->isTherapist()) {
            $tid = $user->therapist->id;
            $conversations = Conversation::with(['lastMessage', 'patient', 'therapist', 'peerTherapist'])
                ->where(function ($q) use ($tid) {
                    $q->where('therapist_id', $tid)
                      ->orWhere('peer_therapist_id', $tid);
                })
                ->orderByDesc('last_message_at')
                ->paginate(20);

            $conversations->getCollection()->transform(function (Conversation $c) use ($tid) {
                if ($c->isTherapistPair()) {
                    $peer = $c->otherTherapist($tid);
                    $c->setAttribute('peer', $peer);
                    $c->setAttribute('partner_id', $peer?->id);
                    $c->setAttribute('partner_type', 'therapist');
                    $c->setAttribute('my_unread', $c->unreadForTherapist($tid));
                } else {
                    $c->setAttribute('peer', $c->patient);
                    $c->setAttribute('partner_id', $c->patient_id);
                    $c->setAttribute('partner_type', 'patient');
                    $c->setAttribute('my_unread', $c->unreadForTherapist($tid));
                }
                return $c;
            });

            return response()->json($conversations);
        }

        $conversations = Conversation::with(['lastMessage', 'therapist'])
            ->where('patient_id', $user->patient->id)
            ->orderByDesc('last_message_at')
            ->paginate(20);

        return response()->json($conversations);
    }

    public function messages(Request $request, Conversation $conversation): JsonResponse
    {
        $this->authorizeConversation($conversation, $request->user());

        $conversation->messages()
            ->where('sender_id', '!=', $request->user()->id)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        $user = $request->user();
        if ($user->isTherapist()) {
            $conversation->clearUnreadForTherapist($user->therapist->id);
        } else {
            $conversation->update(['patient_unread' => 0]);
        }

        $messages = $conversation->messages()
            ->orderByDesc('created_at')
            ->paginate(30);

        return response()->json($messages);
    }

    public function send(Request $request, int $conversationPartnerId): JsonResponse
    {
        $request->validate([
            'content'      => 'nullable|string|max:2000',
            'type'         => 'required|in:text,image,file,voice,video,location',
            'file'         => 'nullable|file|max:51200',
            'partner_type' => 'nullable|in:patient,therapist',
        ]);

        $user = $request->user();
        $partnerType = $request->input('partner_type', 'patient');

        if ($user->isTherapist() && $partnerType === 'therapist') {
            abort_if($conversationPartnerId === $user->therapist->id, 422, 'Cannot message yourself');
            abort_if(!Therapist::where('id', $conversationPartnerId)->where('is_approved', true)->exists(), 404);
            $conversation = Conversation::findOrCreateTherapistPair(
                $user->therapist->id,
                $conversationPartnerId
            );
        } else {
            [$therapistId, $patientId] = $user->isTherapist()
                ? [$user->therapist->id, $conversationPartnerId]
                : [$conversationPartnerId, $user->patient->id];

            $conversation = Conversation::findOrCreate($therapistId, $patientId);
        }

        $mediaUrl = null;
        if ($request->hasFile('file')) {
            $mediaUrl = Storage::disk('public')->url(
                $request->file('file')->store('messages', 'public')
            );
        }

        $message = $conversation->messages()->create([
            'sender_id'  => $user->id,
            'content'    => $request->content,
            'type'       => $request->type,
            'media_url'  => $mediaUrl,
            'media_name' => $request->file('file')?->getClientOriginalName(),
        ]);

        $conversation->last_message_id = $message->id;
        $conversation->last_message_at = now();

        if ($conversation->isTherapistPair()) {
            $conversation->save();
            $conversation->incrementUnreadForOtherTherapist($user->therapist->id);
        } else {
            $unreadField = $user->isTherapist() ? 'patient_unread' : 'therapist_unread';
            $conversation->save();
            $conversation->update([
                $unreadField => \DB::raw("$unreadField + 1"),
            ]);
        }

        $conversation->refresh()->load(['patient', 'therapist', 'peerTherapist']);

        [$recipient, $senderName] = $this->notifyParties($user, $conversation);

        $this->fcmService->send(
            $recipient,
            "رسالة من {$senderName}",
            match ($request->type) {
                'text'     => $request->content,
                'location' => '📍 شارك موقعه',
                default    => '📎 مرفق',
            },
            ['conversation_id' => (string) $conversation->id],
            'new_message'
        );

        return response()->json(['message' => $message], 201);
    }

    /** Generate Agora token for an in-chat voice/video call */
    public function callToken(Request $request, Conversation $conversation): JsonResponse
    {
        $this->authorizeConversation($conversation, $request->user());

        $channel = 'chat_' . $conversation->id;

        return response()->json([
            'channel' => $channel,
            'app_id'  => config('services.agora.app_id'),
            'uid'     => $request->user()->id,
        ]);
    }

    private function notifyParties($user, Conversation $conversation): array
    {
        if ($conversation->isTherapistPair()) {
            $other = $conversation->otherTherapist($user->therapist->id);
            return [$other->user, $user->therapist->full_name];
        }

        $recipient = $user->isTherapist()
            ? $conversation->patient->user
            : $conversation->therapist->user;

        $senderName = $user->isTherapist()
            ? $conversation->therapist->full_name
            : $conversation->patient->full_name;

        return [$recipient, $senderName];
    }

    private function authorizeConversation(Conversation $conversation, $user): void
    {
        if ($user->isTherapist()) {
            $tid = $user->therapist->id;
            $allowed = $conversation->therapist_id === $tid
                || $conversation->peer_therapist_id === $tid;
            abort_if(!$allowed, 403);
            return;
        }

        abort_if($conversation->patient_id !== $user->patient->id, 403);
    }
}
