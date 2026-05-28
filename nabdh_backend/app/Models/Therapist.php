<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Therapist extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id', 'full_name', 'full_name_en', 'avatar', 'bio', 'bio_en',
        'years_experience', 'title', 'gender', 'latitude', 'longitude', 'city', 'degree',
        'is_approved', 'is_verified', 'approved_at', 'accepts_online',
        'accepts_in_person', 'online_session_price', 'in_person_session_price',
        'session_duration', 'rating_average', 'rating_count', 'total_patients',
        'total_sessions', 'is_featured',
    ];

    protected function casts(): array
    {
        return [
            'is_approved' => 'boolean',
            'is_verified' => 'boolean',
            'is_featured' => 'boolean',
            'accepts_online' => 'boolean',
            'accepts_in_person' => 'boolean',
            'approved_at' => 'datetime',
            'rating_average' => 'float',
        ];
    }

    public function user() { return $this->belongsTo(User::class); }
    public function specializations() { return $this->belongsToMany(Specialization::class, 'therapist_specializations'); }
    public function educations() { return $this->hasMany(TherapistEducation::class); }
    public function certifications() { return $this->hasMany(TherapistCertification::class); }
    public function languages() { return $this->hasMany(TherapistLanguage::class); }
    public function documents() { return $this->hasMany(TherapistDocument::class); }
    public function clinics() { return $this->hasMany(Clinic::class); }
    public function schedules() { return $this->hasMany(TherapistSchedule::class); }
    public function unavailabilities() { return $this->hasMany(TherapistUnavailability::class); }
    public function appointments() { return $this->hasMany(Appointment::class); }
    public function reviews() { return $this->hasMany(Review::class); }
    public function reels() { return $this->hasMany(Reel::class); }
    public function homePrograms() { return $this->hasMany(HomeProgram::class); }

    public function recalculateRating(): void
    {
        $avg = $this->reviews()->where('is_visible', true)->avg('rating');
        $count = $this->reviews()->where('is_visible', true)->count();
        $this->update(['rating_average' => round($avg ?? 0, 2), 'rating_count' => $count]);
    }
}
