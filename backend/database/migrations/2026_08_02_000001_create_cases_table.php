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
        Schema::create('cases', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->string('case_number')->nullable();
            $table->string('client_name');
            $table->string('client_phone', 20)->nullable();
            $table->string('court_name')->nullable();
            $table->string('opposing_party')->nullable();
            $table->string('case_type')->nullable();
            $table->enum('status', ['active', 'closed', 'on_hold'])->default('active');
            $table->text('notes')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'status']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('cases');
    }
};

