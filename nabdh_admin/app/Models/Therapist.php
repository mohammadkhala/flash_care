<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Therapist extends Model
{
    protected $fillable = [
        'user_id','full_name','full_name_en','avatar','bio','title','gender',
        'years_experience','city','is_approved','is_verified','approved_at',
        'accepts_online','accepts_in_person','rating_average','rating_count',
        'total_patients','total_sessions','is_featured',
    ];

    protected function casts(): array
    {
        return [
            'is_approved'  => 'boolean',
            'is_verified'  => 'boolean',
            'is_featured'  => 'boolean',
            'accepts_online' => 'boolean',
            'accepts_in_person' => 'boolean',
            'approved_at'  => 'datetime',
        ];
    }

    public function user()            { return $this->belongsTo(User::class); }
    public function specializations() { return $this->belongsToMany(Specialization::class, 'therapist_specializations'); }
    public function documents()       { return $this->hasMany(TherapistDocument::class); }
    public function appointments()    { return $this->hasMany(Appointment::class); }
    public function reviews()         { return $this->hasMany(Review::class); }
    public function reels()           { return $this->hasMany(Reel::class); }
}
