<?php

namespace App\Providers;

use App\Notifications\Channels\NullSmsChannel;
use App\Notifications\Channels\SmsChannel;
use Illuminate\Support\ServiceProvider;

class SmsChannelServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     */
    public function register(): void
    {
        // Swap this binding to a real gateway implementation (one-file change)
        // once a BTRC-approved SMS provider is chosen.
        $this->app->bind(SmsChannel::class, NullSmsChannel::class);
    }

    /**
     * Bootstrap services.
     */
    public function boot(): void
    {
        //
    }
}

