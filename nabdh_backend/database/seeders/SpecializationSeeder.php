<?php

namespace Database\Seeders;

use App\Models\Specialization;
use Illuminate\Database\Seeder;

class SpecializationSeeder extends Seeder
{
    public function run(): void
    {
        $specializations = [
            ['name_ar' => 'علاج طبيعي عام', 'name_en' => 'General Physical Therapy'],
            ['name_ar' => 'علاج عظام ومفاصل', 'name_en' => 'Orthopedic Therapy'],
            ['name_ar' => 'علاج أعصاب', 'name_en' => 'Neurological Therapy'],
            ['name_ar' => 'علاج رياضي', 'name_en' => 'Sports Therapy'],
            ['name_ar' => 'علاج العمود الفقري', 'name_en' => 'Spine Therapy'],
            ['name_ar' => 'علاج حوض وأرضية الحوض', 'name_en' => 'Pelvic Floor Therapy'],
            ['name_ar' => 'علاج وظيفي', 'name_en' => 'Occupational Therapy'],
            ['name_ar' => 'علاج أطفال', 'name_en' => 'Pediatric Therapy'],
            ['name_ar' => 'إعادة التأهيل بعد الجراحة', 'name_en' => 'Post-Surgical Rehabilitation'],
            ['name_ar' => 'علاج سرطان', 'name_en' => 'Oncology Rehabilitation'],
            ['name_ar' => 'علاج قلب وأوعية', 'name_en' => 'Cardiopulmonary Therapy'],
            ['name_ar' => 'علاج شيخوخة', 'name_en' => 'Geriatric Therapy'],
            ['name_ar' => 'دراما العلاج النفسي الحركي', 'name_en' => 'Psychomotor Therapy'],
            ['name_ar' => 'التأهيل اليدوي', 'name_en' => 'Hand Therapy'],
        ];

        foreach ($specializations as $spec) {
            Specialization::firstOrCreate(['name_en' => $spec['name_en']], $spec);
        }
    }
}
