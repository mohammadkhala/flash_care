<?php

namespace Database\Seeders;

use App\Models\AssessmentSection;
use App\Models\AssessmentTemplate;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

/**
 * Starter physiotherapy assessment library (editable from the admin panel).
 * Normal ROM: AAOS reference values. MMT: Oxford/MRC 0–5. Reflexes: 0–4.
 * Runs only when no sections exist yet.
 */
class AssessmentTemplateSeeder extends Seeder
{
    public function run(): void
    {
        if (AssessmentSection::exists()) {
            $this->command?->info('Assessment library already exists — skipped.');
            return;
        }

        DB::transaction(function () {
            $s = [];
            $sort = 0;

            $add = function (string $key, string $en, string $ar, string $type, array $items,
                             ?string $unit = null, ?float $min = null, ?float $max = null) use (&$s, &$sort) {
                $section = AssessmentSection::create([
                    'name_en' => $en, 'name_ar' => $ar, 'type' => $type, 'unit' => $unit,
                    'scale_min' => $min, 'scale_max' => $max, 'sort' => ++$sort,
                ]);
                foreach (array_values($items) as $i => $item) {
                    [$itemEn, $itemAr, $nMin, $nMax] = $item + [null, null, null, null];
                    $section->items()->create([
                        'name_en' => $itemEn, 'name_ar' => $itemAr,
                        'normal_min' => $nMin, 'normal_max' => $nMax, 'sort' => $i + 1,
                    ]);
                }
                $s[$key] = $section->id;
            };

            $add('subjective', 'Subjective Assessment', 'التقييم الذاتي', 'text', [
                ['Chief Complaint', 'الشكوى الرئيسية'],
                ['History of Present Condition', 'تاريخ الحالة الحالية'],
                ['Past Medical History', 'التاريخ المرضي السابق'],
            ]);

            $add('pain', 'Pain (NRS)', 'الألم (0–10)', 'single_number', [
                ['At Rest', 'أثناء الراحة'],
                ['With Activity', 'مع الحركة'],
                ['Worst in Last 24h', 'الأشد خلال 24 ساعة'],
            ], '/10', 0, 10);

            $add('rom_ul', 'Range of Motion (ROM) — Upper Limb', 'مدى الحركة — الطرف العلوي', 'bilateral_number', [
                ['Shoulder Flexion', 'ثني الكتف', 0, 180],
                ['Shoulder Extension', 'بسط الكتف', 0, 60],
                ['Shoulder Abduction', 'تبعيد الكتف', 0, 180],
                ['Shoulder Adduction', 'تقريب الكتف', 0, 40],
                ['Shoulder Internal Rotation', 'الدوران الداخلي للكتف', 0, 70],
                ['Shoulder External Rotation', 'الدوران الخارجي للكتف', 0, 90],
                ['Elbow Flexion', 'ثني المرفق', 0, 150],
                ['Elbow Extension', 'بسط المرفق', 0, 0],
                ['Forearm Pronation', 'كب الساعد', 0, 80],
                ['Forearm Supination', 'بطح الساعد', 0, 80],
                ['Wrist Flexion', 'ثني الرسغ', 0, 80],
                ['Wrist Extension', 'بسط الرسغ', 0, 70],
                ['Wrist Radial Deviation', 'الانحراف الكعبري', 0, 20],
                ['Wrist Ulnar Deviation', 'الانحراف الزندي', 0, 30],
            ], '°');

            $add('rom_ll', 'Range of Motion (ROM) — Lower Limb', 'مدى الحركة — الطرف السفلي', 'bilateral_number', [
                ['Hip Flexion', 'ثني الورك', 0, 120],
                ['Hip Extension', 'بسط الورك', 0, 30],
                ['Hip Abduction', 'تبعيد الورك', 0, 45],
                ['Hip Adduction', 'تقريب الورك', 0, 20],
                ['Hip Internal Rotation', 'الدوران الداخلي للورك', 0, 45],
                ['Hip External Rotation', 'الدوران الخارجي للورك', 0, 45],
                ['Knee Flexion', 'ثني الركبة', 0, 135],
                ['Knee Extension', 'بسط الركبة', 0, 0],
                ['Ankle Dorsiflexion', 'الثني الظهري للكاحل', 0, 20],
                ['Ankle Plantarflexion', 'الثني الأخمصي للكاحل', 0, 50],
                ['Ankle Inversion', 'قلب القدم للداخل', 0, 35],
                ['Ankle Eversion', 'قلب القدم للخارج', 0, 15],
            ], '°');

            $add('rom_spine', 'Range of Motion (ROM) — Spine', 'مدى الحركة — العمود الفقري', 'single_number', [
                ['Cervical Flexion', 'ثني الرقبة', 0, 45],
                ['Cervical Extension', 'بسط الرقبة', 0, 45],
                ['Lumbar Flexion', 'ثني أسفل الظهر', 0, 80],
                ['Lumbar Extension', 'بسط أسفل الظهر', 0, 25],
            ], '°');

            $add('rom_spine_lr', 'Spine — Lateral Flexion & Rotation', 'العمود الفقري — الانحناء الجانبي والدوران', 'bilateral_number', [
                ['Cervical Lateral Flexion', 'الانحناء الجانبي للرقبة', 0, 45],
                ['Cervical Rotation', 'دوران الرقبة', 0, 60],
                ['Lumbar Lateral Flexion', 'الانحناء الجانبي لأسفل الظهر', 0, 35],
                ['Lumbar Rotation', 'دوران أسفل الظهر', 0, 45],
            ], '°');

            $add('mmt_ul', 'Manual Muscle Testing (MMT) — Upper Limb', 'اختبار قوة العضلات — الطرف العلوي', 'bilateral_grade', [
                ['Shoulder Flexors', 'عضلات ثني الكتف', 5, 5],
                ['Shoulder Extensors', 'عضلات بسط الكتف', 5, 5],
                ['Shoulder Abductors', 'عضلات تبعيد الكتف', 5, 5],
                ['Shoulder Adductors', 'عضلات تقريب الكتف', 5, 5],
                ['Shoulder Internal Rotators', 'عضلات الدوران الداخلي', 5, 5],
                ['Shoulder External Rotators', 'عضلات الدوران الخارجي', 5, 5],
                ['Elbow Flexors', 'عضلات ثني المرفق', 5, 5],
                ['Elbow Extensors', 'عضلات بسط المرفق', 5, 5],
                ['Wrist Flexors', 'عضلات ثني الرسغ', 5, 5],
                ['Wrist Extensors', 'عضلات بسط الرسغ', 5, 5],
            ], '/5', 0, 5);

            $add('mmt_ll', 'Manual Muscle Testing (MMT) — Lower Limb', 'اختبار قوة العضلات — الطرف السفلي', 'bilateral_grade', [
                ['Hip Flexors', 'عضلات ثني الورك', 5, 5],
                ['Hip Extensors', 'عضلات بسط الورك', 5, 5],
                ['Hip Abductors', 'عضلات تبعيد الورك', 5, 5],
                ['Hip Adductors', 'عضلات تقريب الورك', 5, 5],
                ['Knee Flexors', 'عضلات ثني الركبة', 5, 5],
                ['Knee Extensors', 'عضلات بسط الركبة', 5, 5],
                ['Ankle Dorsiflexors', 'عضلات الثني الظهري', 5, 5],
                ['Ankle Plantarflexors', 'عضلات الثني الأخمصي', 5, 5],
                ['Great Toe Extensor', 'باسطة إبهام القدم', 5, 5],
            ], '/5', 0, 5);

            $add('reflexes', 'Deep Tendon Reflexes', 'المنعكسات الوترية', 'bilateral_grade', [
                ['Biceps (C5)', 'ذات الرأسين', 2, 2],
                ['Brachioradialis (C6)', 'العضدية الكعبرية', 2, 2],
                ['Triceps (C7)', 'ثلاثية الرؤوس', 2, 2],
                ['Patellar (L4)', 'الرضفة', 2, 2],
                ['Achilles (S1)', 'وتر أخيل', 2, 2],
            ], '/4', 0, 4);

            $add('tests_shoulder', 'Special Tests — Shoulder', 'اختبارات خاصة — الكتف', 'pos_neg', [
                ['Neer Test'], ['Hawkins-Kennedy Test'], ['Empty Can (Jobe) Test'],
                ['Drop Arm Test'], ["Speed's Test"], ['Apprehension Test'],
            ]);

            $add('tests_knee', 'Special Tests — Knee', 'اختبارات خاصة — الركبة', 'pos_neg', [
                ['Lachman Test'], ['Anterior Drawer Test'], ['Posterior Drawer Test'],
                ['McMurray Test'], ['Valgus Stress Test'], ['Varus Stress Test'],
            ]);

            $add('tests_spine', 'Special Tests — Spine', 'اختبارات خاصة — العمود الفقري', 'pos_neg', [
                ['Straight Leg Raise (SLR)'], ['Slump Test'], ["Spurling's Test"], ['FABER (Patrick) Test'],
            ]);

            $add('plan', 'Assessment & Plan', 'التقييم والخطة', 'text', [
                ['Clinical Impression', 'الانطباع السريري'],
                ['Short-term Goals', 'أهداف قصيرة المدى'],
                ['Long-term Goals', 'أهداف طويلة المدى'],
                ['Treatment Plan', 'الخطة العلاجية'],
            ]);

            $templates = [
                ['Upper Limb Assessment', 'تقييم الطرف العلوي',
                    ['subjective', 'pain', 'rom_ul', 'mmt_ul', 'tests_shoulder', 'plan']],
                ['Lower Limb Assessment', 'تقييم الطرف السفلي',
                    ['subjective', 'pain', 'rom_ll', 'mmt_ll', 'tests_knee', 'plan']],
                ['Spine Assessment', 'تقييم العمود الفقري',
                    ['subjective', 'pain', 'rom_spine', 'rom_spine_lr', 'reflexes', 'tests_spine', 'plan']],
                ['Comprehensive Assessment', 'تقييم شامل', array_keys($s)],
            ];

            foreach ($templates as $i => [$en, $ar, $keys]) {
                $t = AssessmentTemplate::create(['name_en' => $en, 'name_ar' => $ar, 'sort' => $i + 1]);
                $t->sections()->attach(collect($keys)->values()->mapWithKeys(
                    fn ($k, $pos) => [$s[$k] => ['sort' => $pos + 1]]
                )->all());
            }
        });

        $this->command?->info('Assessment library created.');
    }
}
