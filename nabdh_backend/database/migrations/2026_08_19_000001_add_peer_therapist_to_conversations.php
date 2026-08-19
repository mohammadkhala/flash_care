<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('conversations', function (Blueprint $table) {
            $table->dropForeign(['patient_id']);
            $table->dropUnique(['therapist_id', 'patient_id']);
        });

        DB::statement('ALTER TABLE conversations MODIFY patient_id BIGINT UNSIGNED NULL');

        Schema::table('conversations', function (Blueprint $table) {
            $table->foreign('patient_id')->references('id')->on('patients')->nullOnDelete();
            $table->foreignId('peer_therapist_id')->nullable()->after('patient_id')
                ->constrained('therapists')->cascadeOnDelete();
            $table->string('kind', 20)->default('patient')->after('peer_therapist_id');
            $table->unique(['therapist_id', 'patient_id']);
            $table->unique(['therapist_id', 'peer_therapist_id']);
        });
    }

    public function down(): void
    {
        Schema::table('conversations', function (Blueprint $table) {
            $table->dropUnique(['therapist_id', 'peer_therapist_id']);
            $table->dropUnique(['therapist_id', 'patient_id']);
            $table->dropForeign(['peer_therapist_id']);
            $table->dropColumn(['peer_therapist_id', 'kind']);
            $table->dropForeign(['patient_id']);
        });

        DB::statement('ALTER TABLE conversations MODIFY patient_id BIGINT UNSIGNED NOT NULL');

        Schema::table('conversations', function (Blueprint $table) {
            $table->foreign('patient_id')->references('id')->on('patients')->cascadeOnDelete();
            $table->unique(['therapist_id', 'patient_id']);
        });
    }
};
