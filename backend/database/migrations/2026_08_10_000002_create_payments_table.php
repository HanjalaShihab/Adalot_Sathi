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
        Schema::create('payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('reference')->nullable();
            $table->string('method')->default('cash');
            $table->string('status')->default('succeeded');
            $table->decimal('amount', 12, 2);
            $table->string('currency', 10)->default('BDT');
            $table->string('description')->nullable();
            $table->dateTime('paid_at')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'paid_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('payments');
    }
};
