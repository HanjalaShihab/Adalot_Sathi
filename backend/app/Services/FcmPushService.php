<?php

namespace App\Services;

use App\Models\DeviceToken;
use App\Models\User;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use RuntimeException;

class FcmPushService
{
    /**
     * Send a push notification to all of a user's registered devices via FCM.
     *
     * @param  array<string, mixed>  $data  Custom payload (e.g. deadline_id, deep-link).
     */
    public function send(User $user, string $title, string $body, array $data = []): bool
    {
        $tokens = $user->deviceTokens()->pluck('token')->all();

        if (empty($tokens)) {
            Log::info('[Adalot Sathi Push] No device tokens for user', ['user_id' => $user->id]);

            return false;
        }

        $serverKey = config('services.fcm.server_key');

        if (blank($serverKey)) {
            Log::warning('[Adalot Sathi Push] FCM server key not configured; skipping push.', [
                'user_id' => $user->id,
                'deadline_data' => $data,
            ]);

            return false;
        }

        try {
            $response = Http::withToken($serverKey)
                ->asJson()
                ->post('https://fcm.googleapis.com/fcm/send', [
                    'registration_ids' => $tokens,
                    'priority' => 'high',
                    'notification' => [
                        'title' => $title,
                        'body' => $body,
                        'sound' => 'default',
                    ],
                    'data' => $data,
                ]);

            if (! $response->successful()) {
                throw new RuntimeException('FCM responded with '.$response->status());
            }

            return true;
        } catch (\Throwable $e) {
            Log::error('[Adalot Sathi Push] FCM send failed.', [
                'user_id' => $user->id,
                'error' => $e->getMessage(),
            ]);

            return false;
        }
    }
}

