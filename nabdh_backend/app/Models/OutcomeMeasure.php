<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class OutcomeMeasure extends Model
{
    protected $fillable = [
        'name_ar', 'name_en', 'abbreviation', 'description', 'questions', 'is_active',
    ];

    protected $casts = [
        'questions' => 'array',
        'is_active' => 'boolean',
    ];

    public function assessments(): HasMany
    {
        return $this->hasMany(PatientAssessment::class);
    }
}
