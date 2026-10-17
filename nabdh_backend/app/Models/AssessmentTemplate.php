<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AssessmentTemplate extends Model
{
    protected $fillable = ['name_en', 'name_ar', 'description', 'sort', 'is_active'];

    protected function casts(): array
    {
        return ['is_active' => 'boolean'];
    }

    public function sections()
    {
        return $this->belongsToMany(AssessmentSection::class, 'assessment_template_section', 'template_id', 'section_id')
            ->withPivot('sort')
            ->orderByPivot('sort');
    }
}
