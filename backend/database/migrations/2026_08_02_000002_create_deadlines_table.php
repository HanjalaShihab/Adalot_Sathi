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
        Schema::create('deadlines', function (Blueprint $table) {
            $table->id();
            $table->foreignId('case_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->enum('event_type', ['hearing', 'filing', 'appeal', 'other'])->default('hearing');
            $table->date('due_date');
            $table->time('due_time')->nullable();
            $table->text('description')->nullable();
            $table->enum('status', ['pending', 'completed', 'missed'])->default('pending');
            $table->json('reminder_days_before')->default('[7,3,1]');
            $table->timestamps();

            $table->index(['case_id', 'due_date']);
            $table->index(['status', 'due_date']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('deadlines');
    }
};

