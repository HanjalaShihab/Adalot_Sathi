<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class LegalCase extends Model
{
    public const STATUS_ACTIVE = 'active';
    public const STATUS_CLOSED = 'closed';
    public const STATUS_ON_HOLD = 'on_hold';

    /** @use HasFactory<\Database\Factories\LegalCaseFactory> */
    use HasFactory;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'cases';

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
protected $fillable = [
        'user_id',
        'title',
        'case_number',
        'client_name',
        'client_phone',
        'client_email',
        'client_address',
        'court_name',
        'judge_name',
        'bench',
        'opposing_party',
        'opposing_lawyer',
        'case_type',
        'status',
        'notes',
        'filing_date',
        'next_hearing_date',
        'judgment_date',
        'reminder_date',
        'reminder_time',
        'reminder_option',
        'repeat_reminder',
        'professional_fee',
        'paid_amount',
        'due_amount',
        'payment_status',
        'case_progress',
        'ai_flags',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'status' => 'string',
            'filing_date' => 'date:Y-m-d',
            'next_hearing_date' => 'date:Y-m-d',
            'judgment_date' => 'date:Y-m-d',
            'reminder_date' => 'date:Y-m-d',
            'reminder_time' => 'string',
            'repeat_reminder' => 'boolean',
            'professional_fee' => 'decimal:2',
            'paid_amount' => 'decimal:2',
            'due_amount' => 'decimal:2',
            'payment_status' => 'string',
            'case_progress' => 'array',
            'ai_flags' => 'array',
        ];
    }

    /**
     * The user who owns this case.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

/**
     * The deadlines under this case.
     */
    public function deadlines(): HasMany
    {
        return $this->hasMany(Deadline::class, 'case_id');
    }

    /**
     * The documents attached to this case.
     */
    public function documents(): HasMany
    {
        return $this->hasMany(CaseDocument::class, 'case_id');
    }
}

