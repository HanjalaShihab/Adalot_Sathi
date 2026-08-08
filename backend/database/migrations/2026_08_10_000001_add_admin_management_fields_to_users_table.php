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
        Schema::table('users', function (Blueprint $table) {
            $table->enum('verification_status', ['pending', 'verified', 'rejected'])
                ->default('verified')
                ->after('role');
            $table->text('rejection_reason')->nullable()->after('verification_status');
            $table->boolean('is_suspended')->default(false)->after('rejection_reason');
            $table->date('suspended_until')->nullable()->after('is_suspended');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'verification_status',
                'rejection_reason',
                'is_suspended',
                'suspended_until',
            ]);
        });
    }
};
