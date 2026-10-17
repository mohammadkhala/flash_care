<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\StreamedResponse;

/**
 * Verification documents (CV, license, ID…) are stored on the private `local`
 * disk and served only through authenticated routes (admin panel / owner API).
 */
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
        'id_card'     => 'الهوية الشخصية',
        'certificate' => 'شهادة / دبلوم',
        'other'       => 'وثيقة أخرى',
    ];

    protected $appends = ['type_label'];

    public function therapist(): BelongsTo
    {
        return $this->belongsTo(Therapist::class);
    }

    public function getTypeLabelAttribute(): string
    {
        return self::$typeLabels[$this->type] ?? $this->type;
    }

    /** Private disk first; files uploaded before the move may still be on `public`. */
    public function diskName(): ?string
    {
        foreach (['local', 'public'] as $disk) {
            if (Storage::disk($disk)->exists($this->file_path)) return $disk;
        }
        return null;
    }

    public function inlineResponse(): StreamedResponse
    {
        $disk = $this->diskName();
        abort_if($disk === null, 404, 'الملف غير موجود على السيرفر');

        $name = $this->file_name ?: basename($this->file_path);
        return Storage::disk($disk)->response($this->file_path, $name, [
            'Cache-Control' => 'private, no-store',
        ], 'inline');
    }

    public function deleteFile(): void
    {
        foreach (['local', 'public'] as $disk) {
            Storage::disk($disk)->delete($this->file_path);
        }
    }
}
