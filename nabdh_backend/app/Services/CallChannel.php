<?php

namespace App\Services;

use App\Models\Appointment;
use App\Models\Conversation;

/**
 * Call channel names shared by signalling (CallController) and Agora tokens.
 *   nabd-conv-{conversationId}   — call from a chat
 *   nabd-session-{appointmentId} — video session of an appointment
 */
class CallChannel
{
    public static function forConversation(int $id): string
    {
        return 'nabd-conv-' . $id;
    }

    public static function forAppointment(int $id): string
    {
        return 'nabd-session-' . $id;
    }

    /**
     * User IDs allowed to join the channel, or null if the channel is unknown.
     *
     * @return int[]|null
     */
    public static function participants(string $channel): ?array
    {
        if (preg_match('/^nabd-conv-(\d+)$/', $channel, $m)) {
            $conv = Conversation::with(['patient', 'therapist', 'peerTherapist'])->find($m[1]);
            if (!$conv) return null;
            return array_values(array_filter([
                $conv->therapist?->user_id,
                $conv->patient?->user_id,
                $conv->peerTherapist?->user_id,
            ]));
        }

        if (preg_match('/^nabd-session-(\d+)$/', $channel, $m)) {
            $apt = Appointment::with(['patient', 'therapist'])->find($m[1]);
            if (!$apt) return null;
            return array_values(array_filter([
                $apt->therapist?->user_id,
                $apt->patient?->user_id,
            ]));
        }

        return null;
    }

    public static function allows(string $channel, int $userId): bool
    {
        return in_array($userId, array_map('intval', self::participants($channel) ?? []), true);
    }
}
