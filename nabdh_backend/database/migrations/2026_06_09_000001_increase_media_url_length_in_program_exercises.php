<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('program_exercises', function (Blueprint $table) {
            // VARCHAR(255) is too short for long URLs (e.g. Google Drive, YouTube links)
            $table->text('media_url')->nullable()->change();
            $table->text('media_thumbnail')->nullable()->change();
        });
    }

    public function down(): void
    {
        Schema::table('program_exercises', function (Blueprint $table) {
            $table->string('media_url')->nullable()->change();
            $table->string('media_thumbnail')->nullable()->change();
        });
    }
};
