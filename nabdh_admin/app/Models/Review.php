<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Review extends Model
{
    protected $fillable = ['therapist_id','patient_id','appointment_id','rating','comment','is_visible'];
    protected function casts(): array { return ['is_visible' => 'boolean']; }

    public function therapist() { return $this->belongsTo(Therapist::class); }
    public function patient()   { return $this->belongsTo(Patient::class); }
}
