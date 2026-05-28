<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Review extends Model
{
    protected $fillable = [
        'therapist_id', 'patient_id', 'appointment_id',
        'rating', 'comment', 'is_visible', 'published_at',
    ];

    protected $appends = ['patient_name'];

    public function getPatientNameAttribute(): ?string
    {
        return $this->patient?->full_name;
    }

    protected function casts(): array
    {
        return [
            'is_visible' => 'boolean',
            'published_at' => 'datetime',
        ];
    }

    public function therapist() { return $this->belongsTo(Therapist::class); }
    public function patient() { return $this->belongsTo(Patient::class); }
    public function appointment() { return $this->belongsTo(Appointment::class); }

    protected static function booted(): void
    {
        static::saved(function (Review $review) {
            $review->therapist->recalculateRating();
        });
        static::deleted(function (Review $review) {
            $review->therapist->recalculateRating();
        });
    }
}
