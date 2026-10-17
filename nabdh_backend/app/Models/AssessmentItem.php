<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AssessmentItem extends Model
{
    protected $fillable = ['section_id', 'name_en', 'name_ar', 'normal_min', 'normal_max', 'sort', 'is_active'];

    protected function casts(): array
    {
        return [
            'is_active'  => 'boolean',
            'normal_min' => 'float',
            'normal_max' => 'float',
        ];
    }

    public function section() { return $this->belongsTo(AssessmentSection::class, 'section_id'); }
}
