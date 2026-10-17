<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * Production's therapist_documents table predates the current create migration
 * and its `type` enum lacks 'cv', so every CV upload failed in strict mode.
 */
return new class extends Migration
{
    public function up(): void
    {
        if (DB::getDriverName() !== 'mysql') return;

        DB::statement("ALTER TABLE therapist_documents MODIFY `type`
            ENUM('cv', 'license', 'id_card', 'certificate', 'other') NOT NULL DEFAULT 'other'");
    }

    public function down(): void
    {
        // Keep 'cv': narrowing the enum would fail if CV rows exist.
    }
};
