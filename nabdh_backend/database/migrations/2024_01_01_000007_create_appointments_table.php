<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('appointments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('therapist_id')->constrained()->cascadeOnDelete();
            $table->foreignId('patient_id')->constrained()->cascadeOnDelete();
            $table->foreignId('clinic_id')->nullable()->constrained()->nullOnDelete();
            $table->dateTime('scheduled_at');
            $table->integer('duration')->default(60); // minutes
            $table->enum('type', ['in_person', 'online'])->default('in_person');
            $table->enum('status', [
                'pending',
                'confirmed',
                'cancelled_by_patient',
                'cancelled_by_therapist',
                'completed',
                'no_show'
            ])->default('pending');
            $table->string('cancellation_reason')->nullable();
            $table->text('patient_notes')->nullable(); // notes from patient at booking
            $table->string('agora_channel')->nullable(); // for online sessions
            $table->timestamps();
        });

        // SOAP notes and session details after appointment
        Schema::create('session_notes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('appointment_id')->constrained()->cascadeOnDelete();
            $table->text('subjective')->nullable();   // S - what patient says
            $table->text('objective')->nullable();    // O - what therapist observes
            $table->text('assessment')->nullable();   // A - therapist assessment
            $table->text('plan')->nullable();         // P - treatment plan
            $table->integer('pain_scale')->nullable(); // 0-10
            $table->integer('session_number')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('session_notes');
        Schema::dropIfExists('appointments');
    }
};
