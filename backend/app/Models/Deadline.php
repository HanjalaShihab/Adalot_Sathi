<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Deadline extends Model
{
    /** @use HasFactory<\Database\Factories\DeadlineFactory> */
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'case_id',
        'title',
        'event_type',
        'due_date',
        'due_time',
        'description',
        'status',
        'reminder_days_before',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'due_date' => 'date:Y-m-d',
            'due_time' => 'string',
            'reminder_days_before' => 'array',
            'event_type' => 'string',
            'status' => 'string',
        ];
    }

    /**
     * The case this deadline belongs to.
     */
    public function case(): BelongsTo
    {
        return $this->belongsTo(LegalCase::class, 'case_id');
    }
}

