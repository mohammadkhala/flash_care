<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('program_exercises', function (Blueprint $table) {
            $table->string('media_name')->nullable()->after('media_url');
        });
    }

    public function down(): void
    {
        Schema::table('program_exercises', function (Blueprint $table) {
            $table->dropColumn('media_name');
        });
    }
};
