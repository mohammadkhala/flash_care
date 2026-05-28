<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    // This migration assumes the nabdh_backend already ran its migrations.
    // We only ensure the admin password column exists.
    public function up(): void
    {
        if (!Schema::hasColumn('users', 'password')) {
            Schema::table('users', function (Blueprint $table) {
                $table->string('password')->nullable()->after('type');
            });
        }
    }

    public function down(): void {}
};
