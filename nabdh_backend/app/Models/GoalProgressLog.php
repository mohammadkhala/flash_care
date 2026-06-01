<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class GoalProgressLog extends Model
{
    public $timestamps = false;

    protected $fillable = ['goal_id', 'progress', 'notes', 'logged_by'];

    protected function casts(): array
    {
        return ['created_at' => 'datetime'];
    }

    public function goal(): BelongsTo     { return $this->belongsTo(PatientGoal::class, 'goal_id'); }
    public function loggedBy(): BelongsTo { return $this->belongsTo(User::class, 'logged_by'); }
}
