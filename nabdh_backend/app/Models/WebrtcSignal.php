<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class WebrtcSignal extends Model
{
    protected $fillable = [
        'channel', 'caller_id', 'callee_id',
        'offer', 'answer',
        'caller_ice', 'callee_ice',
        'is_video', 'caller_name', 'status',
    ];

    protected $casts = [
        'caller_ice' => 'array',
        'callee_ice' => 'array',
        'is_video'   => 'boolean',
    ];
}
