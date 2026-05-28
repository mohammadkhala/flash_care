<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Program templates (reusable by therapist)
        Schema::create('program_templates', function (Blueprint $table) {
            $table->id();
            $table->foreignId('therapist_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->text('description')->nullable();
            $table->string('category')->nullable();
            $table->timestamps();
        });

        // Assigned home programs per patient
        Schema::create('home_programs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('therapist_id')->constrained()->cascadeOnDelete();
            $table->foreignId('patient_id')->constrained()->cascadeOnDelete();
            $table->foreignId('appointment_id')->nullable()->constrained()->nullOnDelete();
            $table->string('title');
            $table->text('description')->nullable();
            $table->date('start_date');
            $table->date('end_date')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        // Individual exercises within a program
        Schema::create('program_exercises', function (Blueprint $table) {
            $table->id();
            $table->foreignId('home_program_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->text('description')->nullable();
            $table->integer('sets')->nullable();
            $table->integer('reps')->nullable();
            $table->integer('duration_seconds')->nullable(); // hold duration
            $table->string('frequency')->nullable(); // e.g. "مرتين يومياً"
            $table->enum('media_type', ['none', 'image', 'video', 'file', 'link'])->default('none');
            $table->string('media_url')->nullable();
            $table->string('media_thumbnail')->nullable();
            $table->integer('order')->default(0);
            $table->timestamps();
        });

        // Patient compliance tracking
        Schema::create('exercise_completions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('program_exercise_id')->constrained()->cascadeOnDelete();
            $table->foreignId('patient_id')->constrained()->cascadeOnDelete();
            $table->date('completed_date');
            $table->text('patient_note')->nullable();
            $table->integer('pain_before')->nullable(); // 0-10
            $table->integer('pain_after')->nullable();  // 0-10
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('exercise_completions');
        Schema::dropIfExists('program_exercises');
        Schema::dropIfExists('home_programs');
        Schema::dropIfExists('program_templates');
    }
};
