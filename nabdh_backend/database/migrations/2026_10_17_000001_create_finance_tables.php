<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('appointments', function (Blueprint $table) {
            $table->decimal('price', 10, 2)->nullable()->after('duration');
        });

        // Billing party per therapist: an app patient (patient_id) or a walk-in (name/phone only).
        Schema::create('finance_clients', function (Blueprint $table) {
            $table->id();
            $table->foreignId('therapist_id')->constrained()->cascadeOnDelete();
            $table->foreignId('patient_id')->nullable()->constrained()->nullOnDelete();
            $table->unsignedInteger('code');            // P-001 per therapist
            $table->string('name');
            $table->string('phone', 30)->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->unique(['therapist_id', 'code']);
            $table->index(['therapist_id', 'patient_id']);
        });

        Schema::create('invoices', function (Blueprint $table) {
            $table->id();
            $table->foreignId('therapist_id')->constrained()->cascadeOnDelete();
            $table->foreignId('client_id')->constrained('finance_clients')->cascadeOnDelete();
            $table->foreignId('appointment_id')->nullable()->constrained()->nullOnDelete();
            $table->unsignedInteger('number');          // INV-0001 per therapist
            $table->date('issued_at');
            $table->decimal('amount', 10, 2);
            $table->decimal('discount', 10, 2)->default(0);
            $table->string('description')->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->unique(['therapist_id', 'number']);
            $table->index(['therapist_id', 'issued_at']);
        });

        Schema::create('payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('therapist_id')->constrained()->cascadeOnDelete();
            $table->foreignId('client_id')->constrained('finance_clients')->cascadeOnDelete();
            $table->decimal('amount', 10, 2);
            $table->string('method', 20)->default('cash'); // cash | card | bank_transfer | other
            $table->date('paid_at');
            $table->text('notes')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->index(['therapist_id', 'paid_at']);
        });

        Schema::create('expenses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('therapist_id')->constrained()->cascadeOnDelete();
            $table->string('category', 20)->default('other'); // rent | equipment | salaries | supplies | utilities | other
            $table->decimal('amount', 10, 2);
            $table->date('spent_at');
            $table->string('description')->nullable();
            $table->string('receipt_path')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->index(['therapist_id', 'spent_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('expenses');
        Schema::dropIfExists('payments');
        Schema::dropIfExists('invoices');
        Schema::dropIfExists('finance_clients');
        Schema::table('appointments', function (Blueprint $table) {
            $table->dropColumn('price');
        });
    }
};
