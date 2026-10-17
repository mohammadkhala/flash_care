<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Letterhead: English side + professional registration numbers.
        Schema::table('therapists', function (Blueprint $table) {
            $table->string('title_en', 100)->nullable()->after('title');
            $table->string('degree_en', 150)->nullable()->after('degree');
            $table->string('license_number', 50)->nullable()->after('degree_en');   // MoH practice license
            $table->string('syndicate_number', 50)->nullable()->after('license_number');
        });

        Schema::table('clinics', function (Blueprint $table) {
            $table->string('name_en')->nullable()->after('name');
            $table->string('address_en', 500)->nullable()->after('address');
            $table->string('email', 150)->nullable()->after('phone');
            $table->string('website', 150)->nullable()->after('email');
            $table->string('license_number', 50)->nullable()->after('website');     // MoH center license
        });

        Schema::table('patient_reports', function (Blueprint $table) {
            $table->unsignedInteger('number')->nullable()->after('therapist_id');  // RPT-0001 per therapist
            $table->string('report_type', 20)->default('initial')->after('title'); // initial | reassessment | progress | discharge
            $table->string('referral_source', 20)->nullable()->after('report_type'); // self | physician | other
            $table->string('referral_name')->nullable()->after('referral_source');
            $table->string('medical_diagnosis', 500)->nullable()->after('referral_name');
            $table->unsignedTinyInteger('sessions_per_week')->nullable()->after('medical_diagnosis');
            $table->unsignedTinyInteger('plan_weeks')->nullable()->after('sessions_per_week');
            $table->timestamp('finalized_at')->nullable()->after('status');
            $table->unique(['therapist_id', 'number']);
        });

        $this->updatePlanSection();
    }

    /** Library already seeded on the server: align "Assessment & Plan" with the new seeder. */
    private function updatePlanSection(): void
    {
        $section = DB::table('assessment_sections')->where('name_en', 'Assessment & Plan')->first();
        if (!$section) return;

        DB::table('assessment_items')->where('section_id', $section->id)
            ->where('name_en', 'Clinical Impression')
            ->update(['name_en' => 'Physiotherapy Diagnosis', 'name_ar' => 'تشخيص العلاج الطبيعي', 'updated_at' => now()]);

        $wanted = [
            ['Physiotherapy Diagnosis', 'تشخيص العلاج الطبيعي'],
            ['Short-term Goals', 'أهداف قصيرة المدى'],
            ['Long-term Goals', 'أهداف طويلة المدى'],
            ['Treatment Plan', 'الخطة العلاجية'],
            ['Prognosis', 'التوقعات'],
            ['Recommendations / Home Program', 'التوصيات والتمارين المنزلية'],
        ];
        foreach ($wanted as $i => [$en, $ar]) {
            $exists = DB::table('assessment_items')->where('section_id', $section->id)->where('name_en', $en)->exists();
            if ($exists) {
                DB::table('assessment_items')->where('section_id', $section->id)->where('name_en', $en)
                    ->update(['sort' => $i + 1]);
            } else {
                DB::table('assessment_items')->insert([
                    'section_id' => $section->id, 'name_en' => $en, 'name_ar' => $ar,
                    'sort' => $i + 1, 'is_active' => true, 'created_at' => now(), 'updated_at' => now(),
                ]);
            }
        }
    }

    public function down(): void
    {
        Schema::table('patient_reports', function (Blueprint $table) {
            $table->dropUnique(['therapist_id', 'number']);
            $table->dropColumn(['number', 'report_type', 'referral_source', 'referral_name',
                'medical_diagnosis', 'sessions_per_week', 'plan_weeks', 'finalized_at']);
        });
        Schema::table('clinics', function (Blueprint $table) {
            $table->dropColumn(['name_en', 'address_en', 'email', 'website', 'license_number']);
        });
        Schema::table('therapists', function (Blueprint $table) {
            $table->dropColumn(['title_en', 'degree_en', 'license_number', 'syndicate_number']);
        });
    }
};
