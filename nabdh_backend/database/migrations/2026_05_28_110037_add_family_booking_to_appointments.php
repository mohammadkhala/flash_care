<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('appointments', function (Blueprint $table) {
            $table->boolean('is_for_other')->default(false)->after('patient_notes');
            $table->string('other_name')->nullable()->after('is_for_other');
            $table->unsignedTinyInteger('other_age')->nullable()->after('other_name');
            $table->string('other_relation')->nullable()->after('other_age');
        });
    }

    public function down(): void
    {
        Schema::table('appointments', function (Blueprint $table) {
            $table->dropColumn(['is_for_other', 'other_name', 'other_age', 'other_relation']);
        });
    }
};
