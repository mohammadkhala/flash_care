<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Article extends Model
{
    protected $fillable = [
        'therapist_id', 'title', 'content', 'cover_image', 'category', 'is_published', 'views_count',
    ];

    protected function casts(): array
    {
        return ['is_published' => 'boolean'];
    }

    public function therapist() { return $this->belongsTo(Therapist::class); }
}
