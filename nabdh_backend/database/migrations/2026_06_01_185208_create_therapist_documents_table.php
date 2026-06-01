<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // If table already exists from a previous migration, add missing columns
        if (!Schema::hasTable('therapist_documents')) {
            Schema::create('therapist_documents', function (Blueprint $table) {
                $table->id();
                $table->foreignId('therapist_id')->constrained()->cascadeOnDelete();
                $table->enum('type', ['cv', 'license', 'certificate', 'other'])->default('other');
                $table->string('file_path');
                $table->string('file_name');
                $table->string('file_size')->nullable();
                $table->string('label')->nullable();
                $table->timestamps();
            });
        } else {
            Schema::table('therapist_documents', function (Blueprint $table) {
                if (!Schema::hasColumn('therapist_documents', 'file_name')) {
                    $table->string('file_name')->nullable()->after('file_path');
                }
                if (!Schema::hasColumn('therapist_documents', 'file_size')) {
                    $table->string('file_size')->nullable()->after('file_name');
                }
                if (!Schema::hasColumn('therapist_documents', 'label')) {
                    $table->string('label')->nullable()->after('file_size');
                }
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('therapist_documents');
    }
};
