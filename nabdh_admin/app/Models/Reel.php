<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Reel extends Model
{
    protected $fillable = [
        'therapist_id','title','description','video_url',
        'thumbnail_url','status','rejection_reason','views','likes_count','is_active',
    ];

    protected $appends = ['full_video_url', 'full_thumbnail_url'];

    protected function casts(): array
    {
        return ['is_active' => 'boolean'];
    }

    public function therapist()
    {
        return $this->belongsTo(Therapist::class);
    }

    /** Full URL for the video — works whether stored path is relative or absolute */
    public function getFullVideoUrlAttribute(): ?string
    {
        return $this->buildUrl($this->video_url);
    }

    /** Full URL for the thumbnail */
    public function getFullThumbnailUrlAttribute(): ?string
    {
        return $this->buildUrl($this->thumbnail_url);
    }

    private function buildUrl(?string $path): ?string
    {
        if (empty($path)) return null;
        if (str_starts_with($path, 'http')) return $path;

        $backend = rtrim(env('BACKEND_URL', config('app.url')), '/');
        return "{$backend}/storage/{$path}";
    }
}
