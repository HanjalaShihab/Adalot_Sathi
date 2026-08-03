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
            // Personal information.
            $table->string('bar_council_number')->nullable()->after('phone');
            $table->string('chamber_name')->nullable()->after('bar_council_number');
            $table->text('address')->nullable()->after('chamber_name');
            $table->string('district')->nullable()->after('address');
            $table->string('profile_photo')->nullable()->after('district');

            // Professional information.
            $table->unsignedInteger('years_of_experience')->nullable()->after('profile_photo');
            $table->json('practice_areas')->nullable()->after('years_of_experience');
            $table->string('preferred_court')->nullable()->after('practice_areas');

            // Preferences.
            $table->string('app_language', 10)->default('bn')->after('preferred_court');
            $table->json('notification_settings')->nullable()->after('app_language');
            $table->json('reminder_settings')->nullable()->after('notification_settings');
            $table->boolean('dark_mode')->default(false)->after('reminder_settings');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'bar_council_number',
                'chamber_name',
                'address',
                'district',
                'profile_photo',
                'years_of_experience',
                'practice_areas',
                'preferred_court',
                'app_language',
                'notification_settings',
                'reminder_settings',
                'dark_mode',
            ]);
        });
    }
};
