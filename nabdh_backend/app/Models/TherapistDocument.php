<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TherapistDocument extends Model
{
    protected $fillable = [
        'therapist_id', 'type', 'file_path', 'notes',
        'status', 'rejection_reason', 'reviewed_at',
    ];

    protected $casts = ['reviewed_at' => 'datetime'];

    public function therapist(): BelongsTo
    {
        return $this->belongsTo(Therapist::class);
    }
}
