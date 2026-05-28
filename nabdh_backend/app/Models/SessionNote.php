<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SessionNote extends Model
{
    protected $fillable = [
        'appointment_id', 'subjective', 'objective',
        'assessment', 'plan', 'pain_scale', 'session_number',
    ];

    public function appointment()
    {
        return $this->belongsTo(Appointment::class);
    }
}
