<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Education
        Schema::create('therapist_educations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('therapist_id')->constrained()->cascadeOnDelete();
            $table->string('degree');
            $table->string('institution');
            $table->string('field_of_study')->nullable();
            $table->year('graduation_year')->nullable();
            $table->string('certificate_file')->nullable();
            $table->timestamps();
        });

        // Certifications
        Schema::create('therapist_certifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('therapist_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->string('issuing_organization')->nullable();
            $table->date('issue_date')->nullable();
            $table->date('expiry_date')->nullable();
            $table->string('credential_id')->nullable();
            $table->string('file')->nullable();
            $table->timestamps();
        });

        // Languages
        Schema::create('therapist_languages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('therapist_id')->constrained()->cascadeOnDelete();
            $table->string('language');
            $table->enum('proficiency', ['basic', 'conversational', 'fluent', 'native'])->default('fluent');
            $table->timestamps();
        });

        // Documents for verification
        Schema::create('therapist_documents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('therapist_id')->constrained()->cascadeOnDelete();
            $table->enum('type', ['license', 'id_card', 'certificate', 'other']);
            $table->string('file_path');
            $table->string('notes')->nullable();
            $table->enum('status', ['pending', 'approved', 'rejected'])->default('pending');
            $table->string('rejection_reason')->nullable();
            $table->timestamp('reviewed_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('therapist_documents');
        Schema::dropIfExists('therapist_languages');
        Schema::dropIfExists('therapist_certifications');
        Schema::dropIfExists('therapist_educations');
    }
};
