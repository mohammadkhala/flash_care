<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AssessmentSection extends Model
{
    public const TYPES = [
        'bilateral_number' => 'يمين / يسار — رقم (مثل ROM بالدرجات)',
        'bilateral_grade'  => 'يمين / يسار — درجة من مقياس (مثل MMT 0–5)',
        'pos_neg'          => 'يمين / يسار — إيجابي أو سلبي (اختبارات خاصة)',
        'single_number'    => 'قيمة واحدة (مثل الألم 0–10 أو ثني العمود الفقري)',
        'text'             => 'نص حر (الشكوى، الخطة…)',
    ];

    protected $fillable = ['name_en', 'name_ar', 'type', 'unit', 'scale_min', 'scale_max', 'sort', 'is_active'];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'scale_min' => 'float',
            'scale_max' => 'float',
        ];
    }

    public function items() { return $this->hasMany(AssessmentItem::class, 'section_id')->orderBy('sort')->orderBy('id'); }

    public function templates()
    {
        return $this->belongsToMany(AssessmentTemplate::class, 'assessment_template_section', 'section_id', 'template_id');
    }

    public function hasNormalRange(): bool
    {
        return in_array($this->type, ['bilateral_number', 'bilateral_grade', 'single_number'], true);
    }
}
