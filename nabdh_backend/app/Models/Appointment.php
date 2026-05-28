<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Appointment extends Model
{
    protected $fillable = [
        'therapist_id', 'patient_id', 'clinic_id', 'scheduled_at',
        'duration', 'type', 'status', 'cancellation_reason',
        'patient_notes', 'agora_channel',
        'is_for_other', 'other_name', 'other_age', 'other_relation',
    ];

    protected function casts(): array
    {
        return ['scheduled_at' => 'datetime'];
    }

    public function therapist() { return $this->belongsTo(Therapist::class); }
    public function patient() { return $this->belongsTo(Patient::class); }
    public function clinic() { return $this->belongsTo(Clinic::class); }
    public function sessionNote() { return $this->hasOne(SessionNote::class); }
    public function review() { return $this->hasOne(Review::class); }
    public function prescriptions() { return $this->hasMany(Prescription::class); }

    public function isPending(): bool { return $this->status === 'pending'; }
    public function isConfirmed(): bool { return $this->status === 'confirmed'; }
    public function isCompleted(): bool { return $this->status === 'completed'; }
}
