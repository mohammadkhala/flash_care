<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TherapistSchedule extends Model
{
    protected $fillable = [
        'therapist_id', 'clinic_id', 'type', 'day_of_week',
        'start_time', 'end_time', 'slot_duration', 'is_active',
    ];

    protected $casts = ['is_active' => 'boolean'];

    public function therapist(): BelongsTo
    {
        return $this->belongsTo(Therapist::class);
    }

    public function clinic(): BelongsTo
    {
        return $this->belongsTo(Clinic::class);
    }
}
