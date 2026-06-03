<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('webrtc_signals', function (Blueprint $table) {
            $table->id();
            $table->string('channel', 120)->unique();
            $table->foreignId('caller_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('callee_id')->constrained('users')->onDelete('cascade');
            $table->longText('offer')->nullable();
            $table->longText('answer')->nullable();
            $table->json('caller_ice')->nullable();
            $table->json('callee_ice')->nullable();
            $table->boolean('is_video')->default(true);
            $table->string('caller_name')->nullable();
            $table->enum('status', ['ringing', 'active', 'ended', 'rejected', 'missed'])
                  ->default('ringing');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('webrtc_signals');
    }
};
