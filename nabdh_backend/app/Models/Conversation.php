<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Conversation extends Model
{
    protected $fillable = [
        'therapist_id', 'patient_id', 'last_message_id',
        'last_message_at', 'therapist_unread', 'patient_unread',
    ];

    protected function casts(): array
    {
        return ['last_message_at' => 'datetime'];
    }

    public function therapist() { return $this->belongsTo(Therapist::class); }
    public function patient() { return $this->belongsTo(Patient::class); }
    public function messages() { return $this->hasMany(Message::class)->orderBy('created_at'); }
    public function lastMessage() { return $this->belongsTo(Message::class, 'last_message_id'); }

    public static function findOrCreate(int $therapistId, int $patientId): self
    {
        return self::firstOrCreate([
            'therapist_id' => $therapistId,
            'patient_id' => $patientId,
        ]);
    }
}
