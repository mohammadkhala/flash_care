<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('patient_documents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('patient_id')->constrained('patients')->cascadeOnDelete();
            $table->string('title');
            $table->enum('type', ['diagnosis', 'report', 'prescription', 'scan', 'lab', 'other'])
                  ->default('other');
            $table->string('file_url', 1000)->nullable();
            $table->string('file_name')->nullable();
            $table->string('file_mime')->nullable();
            $table->text('notes')->nullable();
            $table->string('doctor_name')->nullable();
            $table->date('document_date')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('patient_documents');
    }
};
