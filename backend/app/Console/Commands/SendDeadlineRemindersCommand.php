<?php

namespace App\Console\Commands;

use App\Jobs\SendDeadlineReminderJob;
use App\Models\Deadline;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class SendDeadlineRemindersCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'reminders:send {--dry-run : Report what would be sent without dispatching jobs}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Scan pending deadlines and dispatch reminders for those whose reminder_days_before matches today.';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $today = now()->startOfDay();
        $dryRun = $this->option('dry-run');

        $deadlines = Deadline::query()
            ->where('status', 'pending')
            ->whereDate('due_date', '>=', $today)
            ->with('case.user')
            ->get();

        $matches = $deadlines->filter(function (Deadline $deadline) use ($today) {
            foreach ($deadline->reminder_days_before ?? [] as $days) {
                $reminderDate = $deadline->due_date?->copy()->subDays((int) $days)->startOfDay();

                if ($reminderDate && $reminderDate->equalTo($today)) {
                    return true;
                }
            }

            return false;
        });

        $this->info("Scanned {$deadlines->count()} pending deadlines; {$matches->count()} match today.");

        foreach ($matches as $deadline) {
            if ($dryRun) {
                $this->line(sprintf(
                    '[DRY RUN] Would remind user #%d about "%s" (due %s).',
                    $deadline->case?->user_id,
                    $deadline->title,
                    $deadline->due_date?->format('Y-m-d'),
                ));

                continue;
            }

            // Prevent duplicate jobs within the same day.
            $alreadyQueued = DB::table('notification_logs')
                ->where('deadline_id', $deadline->id)
                ->where('channel', 'push')
                ->whereDate('sent_at', today())
                ->exists();

            if ($alreadyQueued) {
                $this->line("Skipping {$deadline->title}: already reminded today.");

                continue;
            }

            dispatch(new SendDeadlineReminderJob($deadline));
            $this->line("Dispatched reminder for \"{$deadline->title}\" (due {$deadline->due_date->format('Y-m-d')}).");
        }

        return self::SUCCESS;
    }
}

