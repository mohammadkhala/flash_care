<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('reel_comments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('reel_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->text('body');
            $table->timestamps();
        });

        Schema::table('reels', function (Blueprint $table) {
            $table->integer('comments_count')->default(0)->after('likes_count');
        });
    }

    public function down(): void
    {
        Schema::table('reels', function (Blueprint $table) {
            $table->dropColumn('comments_count');
        });
        Schema::dropIfExists('reel_comments');
    }
};
