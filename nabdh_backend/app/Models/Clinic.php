<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Clinic extends Model
{
    protected $fillable = [
        'therapist_id', 'name', 'name_en', 'address', 'address_en', 'city',
        'latitude', 'longitude', 'phone', 'email', 'website', 'license_number', 'logo_path', 'is_active',
    ];

    protected $appends = ['logo_url'];

    public function getLogoUrlAttribute(): ?string
    {
        return $this->logo_path ? \Illuminate\Support\Facades\Storage::disk('public')->url($this->logo_path) : null;
    }

    protected $casts = [
        'is_active' => 'boolean',
        'latitude'  => 'decimal:8',
        'longitude' => 'decimal:8',
    ];

    public function therapist(): BelongsTo
    {
        return $this->belongsTo(Therapist::class);
    }

    public function schedules(): HasMany
    {
        return $this->hasMany(TherapistSchedule::class);
    }
}
