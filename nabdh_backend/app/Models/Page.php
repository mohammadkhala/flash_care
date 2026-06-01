<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Page extends Model
{
    protected $fillable = [
        'slug', 'title_ar', 'title_en', 'title_he',
        'content_ar', 'content_en', 'content_he', 'is_active',
    ];

    protected $casts = ['is_active' => 'boolean'];
}
