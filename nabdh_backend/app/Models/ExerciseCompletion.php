<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ExerciseCompletion extends Model
{
    protected $fillable = [
        'program_exercise_id', 'patient_id', 'completed_date',
        'patient_note', 'pain_before', 'pain_after',
    ];

    protected $casts = ['completed_date' => 'date'];

    public function exercise(): BelongsTo
    {
        return $this->belongsTo(ProgramExercise::class, 'program_exercise_id');
    }

    public function patient(): BelongsTo
    {
        return $this->belongsTo(Patient::class);
    }
}
