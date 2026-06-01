<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TherapistDocument extends Model
{
    protected $fillable = [
        'therapist_id',
        'type',
        'file_path',
        'file_name',
        'file_size',
        'label',
    ];

    /** Type labels in Arabic */
    public static array $typeLabels = [
        'cv'          => 'السيرة الذاتية',
        'license'     => 'الترخيص المهني',
        'certificate' => 'شهادة / دبلوم',
        'other'       => 'وثيقة أخرى',
    ];

    protected $appends = ['url', 'type_label'];

    public function therapist(): BelongsTo
    {
        return $this->belongsTo(Therapist::class);
    }

    /** Full public URL */
    public function getUrlAttribute(): string
    {
        return asset('storage/' . $this->file_path);
    }

    public function getTypeLabelAttribute(): string
    {
        return self::$typeLabels[$this->type] ?? $this->type;
    }
}
