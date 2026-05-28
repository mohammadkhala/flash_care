<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Appointment extends Model
{
    protected $fillable = ['therapist_id','patient_id','scheduled_at','type','status','duration'];
    protected function casts(): array { return ['scheduled_at' => 'datetime']; }

    public function therapist() { return $this->belongsTo(Therapist::class); }
    public function patient()   { return $this->belongsTo(Patient::class); }
}
