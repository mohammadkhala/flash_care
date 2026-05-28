<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TherapistUnavailability extends Model
{
    protected $fillable = ['therapist_id', 'date', 'start_time', 'end_time', 'reason'];

    protected $casts = ['date' => 'date'];

    public function therapist(): BelongsTo
    {
        return $this->belongsTo(Therapist::class);
    }
}
