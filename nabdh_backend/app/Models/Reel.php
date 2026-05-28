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
}
