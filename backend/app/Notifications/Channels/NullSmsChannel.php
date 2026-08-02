<?php

namespace App\Notifications\Channels;

use Illuminate\Support\Facades\Log;

/**
 * Provider-agnostic stub used until a real BTRC-approved gateway is chosen.
 *
 * Logs the would-be SMS so delivery logic can be tested end-to-end without
 * spending money or depending on an external provider.
 */
class NullSmsChannel implements SmsChannel
{
    public function sendSms(string $phone, string $message): void
    {
        Log::info('[Adalot Sathi SMS] Would send SMS', [
            'to' => $phone,
            'message' => $message,
        ]);
    }
}

