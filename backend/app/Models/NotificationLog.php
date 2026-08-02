<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class NotificationLog extends Model
{
    /** @use HasFactory<\Database\Factories\NotificationLogFactory> */
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'user_id',
        'deadline_id',
        'channel',
        'status',
        'error_message',
        'sent_at',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'sent_at' => 'datetime',
        ];
    }

    /**
     * The user this notification was sent to.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * The deadline this notification was about.
     */
    public function deadline(): BelongsTo
    {
        return $this->belongsTo(Deadline::class);
    }
}

