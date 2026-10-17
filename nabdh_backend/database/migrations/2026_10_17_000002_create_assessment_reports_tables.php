<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Admin-defined categories (ROM, MMT, …) and their rows.
        Schema::create('assessment_sections', function (Blueprint $table) {
            $table->id();
            $table->string('name_en');
            $table->string('name_ar');
            // bilateral_number | bilateral_grade | pos_neg | single_number | text
            $table->string('type', 20);
            $table->string('unit', 20)->nullable();          // °, cm, …
            $table->decimal('scale_min', 6, 2)->nullable();   // grade / scale bounds
            $table->decimal('scale_max', 6, 2)->nullable();
            $table->unsignedSmallInteger('sort')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('assessment_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('section_id')->constrained('assessment_sections')->cascadeOnDelete();
            $table->string('name_en');
            $table->string('name_ar')->nullable();
            $table->decimal('normal_min', 8, 2)->nullable();
            $table->decimal('normal_max', 8, 2)->nullable();
            $table->unsignedSmallInteger('sort')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('assessment_templates', function (Blueprint $table) {
            $table->id();
            $table->string('name_en');
            $table->string('name_ar');
            $table->string('description')->nullable();
            $table->unsignedSmallInteger('sort')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('assessment_template_section', function (Blueprint $table) {
            $table->foreignId('template_id')->constrained('assessment_templates')->cascadeOnDelete();
            $table->foreignId('section_id')->constrained('assessment_sections')->cascadeOnDelete();
            $table->unsignedSmallInteger('sort')->default(0);
            $table->primary(['template_id', 'section_id']);
        });

        // A filled assessment. `data` snapshots section/item names and normal
        // ranges so later template edits never change an existing report.
        Schema::create('patient_reports', function (Blueprint $table) {
            $table->id();
            $table->foreignId('therapist_id')->constrained()->cascadeOnDelete();
            $table->foreignId('client_id')->constrained('finance_clients')->cascadeOnDelete();
            $table->foreignId('clinic_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('template_id')->nullable()->constrained('assessment_templates')->nullOnDelete();
            $table->foreignId('appointment_id')->nullable()->constrained()->nullOnDelete();
            $table->string('title');
            $table->date('assessed_at');
            $table->json('data');
            $table->text('notes')->nullable();
            $table->string('status', 10)->default('draft');  // draft | final
            $table->timestamps();
            $table->softDeletes();

            $table->index(['therapist_id', 'client_id']);
        });

        Schema::table('clinics', function (Blueprint $table) {
            $table->string('logo_path')->nullable()->after('phone');
        });
    }

    public function down(): void
    {
        Schema::table('clinics', function (Blueprint $table) {
            $table->dropColumn('logo_path');
        });
        Schema::dropIfExists('patient_reports');
        Schema::dropIfExists('assessment_template_section');
        Schema::dropIfExists('assessment_templates');
        Schema::dropIfExists('assessment_items');
        Schema::dropIfExists('assessment_sections');
    }
};
