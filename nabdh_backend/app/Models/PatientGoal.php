<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class PatientGoal extends Model
{
    protected $fillable = [
        'therapist_id', 'patient_id', 'appointment_id',
        'title', 'description', 'target_date', 'extended_date',
        'current_progress', 'status',
    ];

    protected function casts(): array
    {
        return [
            'target_date'   => 'date',
            'extended_date' => 'date',
        ];
    }

    public function therapist(): BelongsTo { return $this->belongsTo(Therapist::class); }
    public function patient(): BelongsTo   { return $this->belongsTo(Patient::class); }
    public function progressLogs(): HasMany { return $this->hasMany(GoalProgressLog::class, 'goal_id')->latest(); }

    /** Effective end date: extended if set, otherwise target */
    public function getEffectiveDateAttribute(): string
    {
        return ($this->extended_date ?? $this->target_date)->toDateString();
    }
}
