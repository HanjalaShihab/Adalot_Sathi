<?php

namespace App\Notifications\Channels;

/**
 * Swappable SMS channel contract.
 *
 * The concrete gateway implementation is intentionally NOT hardcoded yet.
 * Once you pick a BTRC-approved bulk SMS provider, implement this interface
 * (or swap the binding in a service provider) without touching callers.
 */
interface SmsChannel
{
    /**
     * Send a single SMS to a Bangladeshi number.
     *
     * @param  string  $phone  Recipient number in 01XXXXXXXXX format.
     * @param  string  $message  The SMS body.
     *
     * @throws \RuntimeException When the gateway rejects the send.
     */
    public function sendSms(string $phone, string $message): void;
}

