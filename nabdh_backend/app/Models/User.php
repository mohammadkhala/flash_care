<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'phone', 'phone_country_code', 'otp', 'otp_expires_at',
        'type', 'fcm_token', 'is_active', 'phone_verified_at', 'password',
    ];

    protected $hidden = ['otp', 'password', 'remember_token'];

    protected function casts(): array
    {
        return [
            'phone_verified_at' => 'datetime',
            'otp_expires_at' => 'datetime',
            'is_active' => 'boolean',
        ];
    }

    public function therapist()
    {
        return $this->hasOne(Therapist::class);
    }

    public function patient()
    {
        return $this->hasOne(Patient::class);
    }

    public function pushNotifications()
    {
        return $this->hasMany(PushNotification::class);
    }

    public function isTherapist(): bool { return $this->type === 'therapist'; }
    public function isPatient(): bool { return $this->type === 'patient'; }
    public function isAdmin(): bool { return $this->type === 'admin'; }

    public function isOtpValid(string $otp): bool
    {
        return $this->otp === $otp && $this->otp_expires_at?->isFuture();
    }
}
