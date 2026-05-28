<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PatientAssessment extends Model
{
    protected $fillable = [
        'therapist_id', 'patient_id', 'appointment_id',
        'outcome_measure_id', 'answers', 'score', 'interpretation',
    ];

    protected $casts = ['answers' => 'array'];

    public function therapist(): BelongsTo
    {
        return $this->belongsTo(Therapist::class);
    }

    public function patient(): BelongsTo
    {
        return $this->belongsTo(Patient::class);
    }

    public function outcomeMeasure(): BelongsTo
    {
        return $this->belongsTo(OutcomeMeasure::class);
    }
}
