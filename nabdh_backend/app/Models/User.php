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

    /** Palestinian mobiles share one numbering plan: +970 59… is the same line as +972 59…. */
    public const SHARED_PLAN_CODES = ['+970', '+972'];

    /** Digits only, without the local trunk "0" (059… → 59…). */
    public static function normalizePhone(string $phone): string
    {
        return ltrim(preg_replace('/\D+/', '', $phone), '0');
    }

    /**
     * Match a phone the way users type it: with or without the leading 0, and
     * +970/+972 as the same number. Verified accounts with a password first,
     * so older duplicates (saved with a leading 0) don't win.
     */
    public function scopeWherePhone($query, string $countryCode, string $phone)
    {
        $local = self::normalizePhone($phone);
        $codes = in_array($countryCode, self::SHARED_PLAN_CODES, true)
            ? self::SHARED_PLAN_CODES
            : [$countryCode];

        return $query->whereIn('phone', [$local, '0' . $local])
            ->whereIn('phone_country_code', $codes)
            ->orderByRaw('password IS NULL')
            ->orderByRaw('phone_verified_at IS NULL')
            ->orderBy('id');
    }

    public function isOtpValid(string $otp): bool
    {
        return $this->otp === $otp && $this->otp_expires_at?->isFuture();
    }
}
