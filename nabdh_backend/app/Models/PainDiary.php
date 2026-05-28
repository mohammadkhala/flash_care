<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PainDiary extends Model
{
    protected $table = 'pain_diary';

    protected $fillable = ['patient_id', 'date', 'pain_scale', 'body_part', 'notes'];

    protected $casts = ['date' => 'date'];

    public function patient(): BelongsTo
    {
        return $this->belongsTo(Patient::class);
    }
}
