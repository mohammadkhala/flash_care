<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // therapist_id FK currently sits on the composite unique index, so
        // add a dedicated index before dropping that unique key.
        Schema::table('conversations', function (Blueprint $table) {
            $table->index('therapist_id', 'conversations_therapist_id_index');
        });

        Schema::table('conversations', function (Blueprint $table) {
            $table->dropUnique('conversations_therapist_id_patient_id_unique');
        });

        DB::statement('ALTER TABLE conversations MODIFY patient_id BIGINT UNSIGNED NULL');

        Schema::table('conversations', function (Blueprint $table) {
            $table->unsignedBigInteger('peer_therapist_id')->nullable()->after('patient_id');
            $table->string('kind', 20)->default('patient')->after('peer_therapist_id');
        });

        Schema::table('conversations', function (Blueprint $table) {
            $table->foreign('peer_therapist_id')
                ->references('id')->on('therapists')->cascadeOnDelete();
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
        });

        DB::statement('ALTER TABLE conversations MODIFY patient_id BIGINT UNSIGNED NOT NULL');

        Schema::table('conversations', function (Blueprint $table) {
            $table->unique(['therapist_id', 'patient_id']);
            $table->dropIndex('conversations_therapist_id_index');
        });
    }
};
