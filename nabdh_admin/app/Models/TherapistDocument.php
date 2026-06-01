<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TherapistDocument extends Model
{
    protected $fillable = ['therapist_id','type','file_path','status','rejection_reason','reviewed_at'];
    protected function casts(): array { return ['reviewed_at' => 'datetime']; }

    public function therapist() { return $this->belongsTo(Therapist::class); }
}
