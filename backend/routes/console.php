<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Daily scan for deadline reminders. Runs at 8am Dhaka time.
Schedule::command('reminders:send')
    ->dailyAt('08:00')
    ->withoutOverlapping()
    ->onOneServer();
