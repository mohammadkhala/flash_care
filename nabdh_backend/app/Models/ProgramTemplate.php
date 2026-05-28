<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ProgramTemplate extends Model
{
    protected $fillable = ['therapist_id', 'title', 'description', 'category'];

    public function therapist(): BelongsTo
    {
        return $this->belongsTo(Therapist::class);
    }
}
