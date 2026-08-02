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
        'court_name',
        'opposing_party',
        'case_type',
        'status',
        'notes',
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
}

