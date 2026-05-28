<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class HomeProgram extends Model
{
    protected $fillable = [
        'therapist_id', 'patient_id', 'appointment_id', 'title',
        'description', 'start_date', 'end_date', 'is_active',
    ];

    protected function casts(): array
    {
        return [
            'start_date' => 'date',
            'end_date' => 'date',
            'is_active' => 'boolean',
        ];
    }

    public function therapist() { return $this->belongsTo(Therapist::class); }
    public function patient() { return $this->belongsTo(Patient::class); }
    public function exercises() { return $this->hasMany(ProgramExercise::class)->orderBy('order'); }

    public function complianceRate(): float
    {
        $total = $this->exercises->count();
        if ($total === 0) return 0;

        $days = $this->start_date->diffInDays(now()) + 1;
        $expected = $total * $days;
        $completed = ProgramExercise::whereIn('id', $this->exercises->pluck('id'))
            ->withCount('completions')
            ->get()
            ->sum('completions_count');

        return $expected > 0 ? round(($completed / $expected) * 100, 1) : 0;
    }
}
