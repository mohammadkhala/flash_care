<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('goal_progress_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('goal_id')->constrained('patient_goals')->cascadeOnDelete();
            $table->unsignedTinyInteger('progress'); // 0-100
            $table->text('notes')->nullable();
            $table->foreignId('logged_by')->constrained('users')->cascadeOnDelete();
            $table->timestamp('created_at')->useCurrent();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('goal_progress_logs');
    }
};
