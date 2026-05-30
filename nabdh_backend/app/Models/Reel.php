<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Reel extends Model
{
    protected $fillable = [
        'therapist_id', 'title', 'description', 'video_url',
        'thumbnail_url', 'duration_seconds', 'views', 'likes_count', 'comments_count',
        'status', 'rejection_reason', 'is_active',
    ];

    protected function casts(): array
    {
        return ['is_active' => 'boolean'];
    }

    public function therapist()  { return $this->belongsTo(Therapist::class); }
    public function likes()      { return $this->hasMany(ReelLike::class); }
    public function comments()   { return $this->hasMany(ReelComment::class); }

    public function isLikedBy(User $user): bool
    {
        return $this->likes()->where('user_id', $user->id)->exists();
    }

    /** Full URL for the video (used by admin panel) */
    public function getFullVideoUrlAttribute(): ?string
    {
        return $this->buildStorageUrl($this->video_url);
    }

    /** Full URL for the thumbnail (used by admin panel) */
    public function getFullThumbnailUrlAttribute(): ?string
    {
        return $this->buildStorageUrl($this->thumbnail_url);
    }

    private function buildStorageUrl(?string $path): ?string
    {
        if (empty($path)) return null;
        if (str_starts_with($path, 'http')) return $path;
        return rtrim(config('app.url'), '/') . '/storage/' . $path;
    }
}
