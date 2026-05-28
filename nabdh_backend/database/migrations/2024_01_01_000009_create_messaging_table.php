<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // conversations first (without last_message_id FK)
        Schema::create('conversations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('therapist_id')->constrained()->cascadeOnDelete();
            $table->foreignId('patient_id')->constrained()->cascadeOnDelete();
            $table->unsignedBigInteger('last_message_id')->nullable(); // FK added after messages table
            $table->timestamp('last_message_at')->nullable();
            $table->integer('therapist_unread')->default(0);
            $table->integer('patient_unread')->default(0);
            $table->timestamps();

            $table->unique(['therapist_id', 'patient_id']);
        });

        // messages second
        Schema::create('messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('conversation_id')->constrained()->cascadeOnDelete();
            $table->foreignId('sender_id')->constrained('users')->cascadeOnDelete();
            $table->text('content')->nullable();
            $table->enum('type', ['text', 'image', 'file', 'voice', 'video'])->default('text');
            $table->string('media_url')->nullable();
            $table->string('media_name')->nullable();
            $table->integer('media_size')->nullable();
            $table->integer('voice_duration')->nullable();
            $table->timestamp('read_at')->nullable();
            $table->boolean('is_deleted')->default(false);
            $table->timestamps();
        });

        // Now add the FK from conversations → messages
        Schema::table('conversations', function (Blueprint $table) {
            $table->foreign('last_message_id')->references('id')->on('messages')->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('conversations', function (Blueprint $table) {
            $table->dropForeign(['last_message_id']);
        });
        Schema::dropIfExists('messages');
        Schema::dropIfExists('conversations');
    }
};
