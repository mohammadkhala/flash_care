<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Specialization extends Model
{
    protected $fillable = ['name_ar','name_en','icon','is_active'];
    protected function casts(): array { return ['is_active' => 'boolean']; }

    public function therapists() { return $this->belongsToMany(Therapist::class, 'therapist_specializations'); }
}
