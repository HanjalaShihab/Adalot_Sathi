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
        Schema::table('cases', function (Blueprint $table) {
            // Client information.
            $table->string('client_email')->nullable()->after('client_phone');
            $table->text('client_address')->nullable()->after('client_email');

            // Court information.
            $table->string('judge_name')->nullable()->after('court_name');
            $table->string('bench')->nullable()->after('judge_name');

            // Important dates & reminders.
            $table->date('filing_date')->nullable()->after('case_type');
            $table->date('next_hearing_date')->nullable()->after('filing_date');
            $table->date('judgment_date')->nullable()->after('next_hearing_date');
            $table->date('reminder_date')->nullable()->after('judgment_date');
            $table->time('reminder_time')->nullable()->after('reminder_date');
            $table->string('reminder_option')->nullable()->after('reminder_time');
            $table->boolean('repeat_reminder')->default(false)->after('reminder_option');

            // Opposing party.
            $table->string('opposing_lawyer')->nullable()->after('opposing_party');

            // Financial information.
            $table->decimal('professional_fee', 12, 2)->nullable()->after('notes');
            $table->decimal('paid_amount', 12, 2)->nullable()->after('professional_fee');
            $table->decimal('due_amount', 12, 2)->nullable()->after('paid_amount');
            $table->enum('payment_status', ['paid', 'partial', 'unpaid'])->default('unpaid')->after('due_amount');

            // Case progress timeline + AI placeholder.
            $table->json('case_progress')->nullable()->after('payment_status');
            $table->json('ai_flags')->nullable()->after('case_progress');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('cases', function (Blueprint $table) {
            $table->dropColumn([
                'client_email',
                'client_address',
                'judge_name',
                'bench',
                'filing_date',
                'next_hearing_date',
                'judgment_date',
                'reminder_date',
                'reminder_time',
                'reminder_option',
                'repeat_reminder',
                'opposing_lawyer',
                'professional_fee',
                'paid_amount',
                'due_amount',
                'payment_status',
                'case_progress',
                'ai_flags',
            ]);
        });
    }
};
