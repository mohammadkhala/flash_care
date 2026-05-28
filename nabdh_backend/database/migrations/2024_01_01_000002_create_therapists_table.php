<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('therapists', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('full_name');
            $table->string('full_name_en')->nullable();
            $table->string('avatar')->nullable();
            $table->text('bio')->nullable();
            $table->text('bio_en')->nullable();
            $table->integer('years_experience')->default(0);
            $table->string('title')->nullable(); // e.g. دكتور علاج طبيعي
            $table->enum('gender', ['male', 'female'])->nullable();
            $table->decimal('latitude', 10, 8)->nullable();
            $table->decimal('longitude', 11, 8)->nullable();
            $table->string('city')->nullable();
            $table->boolean('is_approved')->default(false);
            $table->boolean('is_verified')->default(false);
            $table->timestamp('approved_at')->nullable();
            $table->boolean('accepts_online')->default(false);
            $table->boolean('accepts_in_person')->default(true);
            $table->decimal('online_session_price', 8, 2)->nullable();
            $table->decimal('in_person_session_price', 8, 2)->nullable();
            $table->integer('session_duration')->default(60); // minutes
            $table->decimal('rating_average', 3, 2)->default(0);
            $table->integer('rating_count')->default(0);
            $table->integer('total_patients')->default(0);
            $table->integer('total_sessions')->default(0);
            $table->boolean('is_featured')->default(false);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('therapists');
    }
};
