<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ProgramExercise extends Model
{
    protected $fillable = [
        'home_program_id', 'title', 'description', 'sets', 'reps',
        'duration_seconds', 'frequency', 'media_type', 'media_url',
        'media_name', 'media_thumbnail', 'order',
    ];

    public function homeProgram(): BelongsTo
    {
        return $this->belongsTo(HomeProgram::class);
    }

    public function completions(): HasMany
    {
        return $this->hasMany(ExerciseCompletion::class);
    }
}
