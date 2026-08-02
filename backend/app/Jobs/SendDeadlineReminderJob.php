<?php

namespace App\Jobs;

use App\Models\Deadline;
use App\Models\NotificationLog;
use App\Models\User;
use App\Notifications\Channels\SmsChannel;
use App\Services\FcmPushService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Log;

class SendDeadlineReminderJob implements ShouldQueue
{
    use Queueable;

    /**
     * Create a new job instance.
     */
    public function __construct(
        public readonly Deadline $deadline,
    ) {
    }

    /**
     * Execute the job.
     */
    public function handle(FcmPushService $fcm, SmsChannel $sms): void
    {
        $user = $this->deadline->case?->user;

        if (! $user) {
            Log::warning('[Adalot Sathi] Reminder job skipped: no owning user for deadline', [
                'deadline_id' => $this->deadline->id,
            ]);

            return;
        }

        $title = 'Adalot Sathi: Upcoming Deadline';
        $body = sprintf(
            '"%s" for %s is due on %s (%s).',
            $this->deadline->title,
            $this->deadline->case?->client_name ?? 'your case',
            $this->deadline->due_date?->format('d M Y'),
            $this->deadline->due_time ?? 'end of day',
        );

        $data = [
            'type' => 'deadline_reminder',
            'deadline_id' => (string) $this->deadline->id,
            'case_id' => (string) $this->deadline->case_id,
        ];

        // Free tier: push only.
        $pushSent = $fcm->send($user, $title, $body, $data);

        $this->logNotification($user, $this->deadline, 'push', $pushSent ? 'sent' : 'failed');

        // Paid tier: push + SMS.
        if ($user->isPaid()) {
            try {
                $smsPhone = $user->phone;
                if ($smsPhone) {
                    $smsBody = sprintf(
                        'Adalot Sathi: "%s" due %s %s. Court: %s. - Adalot Sathi',
                        $this->deadline->title,
                        $this->deadline->due_date?->format('d/m/Y'),
                        $this->deadline->due_time ?? '',
                        $this->deadline->case?->court_name ?? 'N/A',
                    );

                    $sms->sendSms($smsPhone, $smsBody);
                    $this->logNotification($user, $this->deadline, 'sms', 'sent');
                } else {
                    $this->logNotification($user, $this->deadline, 'sms', 'failed');
                }
            } catch (\Throwable $e) {
                Log::error('[Adalot Sathi] SMS send failed.', [
                    'deadline_id' => $this->deadline->id,
                    'user_id' => $user->id,
                    'error' => $e->getMessage(),
                ]);
                $this->logNotification($user, $this->deadline, 'sms', 'failed');
            }
        }
    }

    /**
     * Record a reminder attempt in the notification_log table.
     */
    private function logNotification(User $user, Deadline $deadline, string $channel, string $status): void
    {
        NotificationLog::create([
            'user_id' => $user->id,
            'deadline_id' => $deadline->id,
            'channel' => $channel,
            'status' => $status,
            'sent_at' => now(),
        ]);
    }
}

