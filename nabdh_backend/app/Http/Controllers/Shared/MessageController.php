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

        $query = Conversation::with(['lastMessage']);

        if ($user->isTherapist()) {
            $conversations = $query->where('therapist_id', $user->therapist->id)
                ->with('patient')
                ->orderByDesc('last_message_at')
                ->paginate(20);
        } else {
            $conversations = $query->where('patient_id', $user->patient->id)
                ->with('therapist')
                ->orderByDesc('last_message_at')
                ->paginate(20);
        }

        return response()->json($conversations);
    }

    public function messages(Request $request, Conversation $conversation): JsonResponse
    {
        $this->authorizeConversation($conversation, $request->user());

        // Mark messages as read
        $conversation->messages()
            ->where('sender_id', '!=', $request->user()->id)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        $field = $request->user()->isTherapist() ? 'therapist_unread' : 'patient_unread';
        $conversation->update([$field => 0]);

        $messages = $conversation->messages()
            ->orderByDesc('created_at')
            ->paginate(30);

        return response()->json($messages);
    }

    public function send(Request $request, int $conversationPartnerId): JsonResponse
    {
        $request->validate([
            'content' => 'nullable|string|max:2000',
            'type' => 'required|in:text,image,file,voice,video,location',
            'file' => 'nullable|file|max:51200',
        ]);

        $user = $request->user();

        [$therapistId, $patientId] = $user->isTherapist()
            ? [$user->therapist->id, $conversationPartnerId]
            : [$conversationPartnerId, $user->patient->id];

        $conversation = Conversation::findOrCreate($therapistId, $patientId);

        $mediaUrl = null;
        if ($request->hasFile('file')) {
            $mediaUrl = Storage::disk('public')->url(
                $request->file('file')->store('messages', 'public')
            );
        }

        $message = $conversation->messages()->create([
            'sender_id' => $user->id,
            'content' => $request->content,
            'type' => $request->type,
            'media_url' => $mediaUrl,
            'media_name' => $request->file('file')?->getClientOriginalName(),
        ]);

        $conversation->update([
            'last_message_id' => $message->id,
            'last_message_at' => now(),
            ($user->isTherapist() ? 'patient_unread' : 'therapist_unread') => \DB::raw(
                ($user->isTherapist() ? 'patient_unread' : 'therapist_unread') . ' + 1'
            ),
        ]);

        // Notify recipient
        $recipient = $user->isTherapist()
            ? $conversation->patient->user
            : $conversation->therapist->user;

        $senderName = $user->isTherapist()
            ? $conversation->therapist->full_name
            : $conversation->patient->full_name;

        $this->fcmService->send(
            $recipient,
            "رسالة من {$senderName}",
            match($request->type) {
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

    private function authorizeConversation(Conversation $conversation, $user): void
    {
        $allowed = $user->isTherapist()
            ? $conversation->therapist_id === $user->therapist->id
            : $conversation->patient_id === $user->patient->id;

        abort_if(!$allowed, 403);
    }
}
