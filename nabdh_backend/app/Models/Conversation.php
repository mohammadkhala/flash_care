<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Conversation extends Model
{
    protected $fillable = [
        'therapist_id', 'patient_id', 'peer_therapist_id', 'kind',
        'last_message_id', 'last_message_at', 'therapist_unread', 'patient_unread',
    ];

    protected function casts(): array
    {
        return ['last_message_at' => 'datetime'];
    }

    public function therapist() { return $this->belongsTo(Therapist::class); }
    public function patient() { return $this->belongsTo(Patient::class); }
    public function peerTherapist() { return $this->belongsTo(Therapist::class, 'peer_therapist_id'); }
    public function messages() { return $this->hasMany(Message::class)->orderBy('created_at'); }
    public function lastMessage() { return $this->belongsTo(Message::class, 'last_message_id'); }

    public function isTherapistPair(): bool
    {
        return $this->kind === 'therapist' || $this->peer_therapist_id !== null;
    }

    public static function findOrCreate(int $therapistId, int $patientId): self
    {
        return self::firstOrCreate([
            'therapist_id' => $therapistId,
            'patient_id'   => $patientId,
            'kind'         => 'patient',
        ]);
    }

    public static function findOrCreateTherapistPair(int $a, int $b): self
    {
        $low  = min($a, $b);
        $high = max($a, $b);

        return self::firstOrCreate(
            [
                'therapist_id'      => $low,
                'peer_therapist_id' => $high,
                'kind'              => 'therapist',
            ],
            ['patient_id' => null]
        );
    }

    public function otherTherapist(int $myTherapistId): ?Therapist
    {
        if (!$this->isTherapistPair()) return null;

        return $this->therapist_id === $myTherapistId
            ? $this->peerTherapist
            : $this->therapist;
    }

    public function unreadForTherapist(int $myTherapistId): int
    {
        if ($this->isTherapistPair()) {
            return $this->therapist_id === $myTherapistId
                ? (int) $this->therapist_unread
                : (int) $this->patient_unread;
        }

        return (int) $this->therapist_unread;
    }

    public function incrementUnreadForOtherTherapist(int $senderTherapistId): void
    {
        $field = $this->therapist_id === $senderTherapistId
            ? 'patient_unread'
            : 'therapist_unread';

        $this->update([$field => \DB::raw("$field + 1")]);
    }

    public function clearUnreadForTherapist(int $myTherapistId): void
    {
        $field = $this->isTherapistPair() && $this->therapist_id !== $myTherapistId
            ? 'patient_unread'
            : 'therapist_unread';

        $this->update([$field => 0]);
    }
}
