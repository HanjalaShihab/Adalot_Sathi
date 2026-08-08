<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
'phone',
        'password',
        'role',
        'verification_status',
        'rejection_reason',
        'is_suspended',
        'suspended_until',
        'subscription_tier',
        'subscription_expires_at',
        'bar_council_number',
        'chamber_name',
        'address',
        'district',
        'profile_photo',
        'years_of_experience',
        'practice_areas',
        'preferred_court',
        'app_language',
        'notification_settings',
        'reminder_settings',
        'dark_mode',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
* @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
'password' => 'hashed',
            'subscription_expires_at' => 'date',
            'role' => 'string',
            'verification_status' => 'string',
            'rejection_reason' => 'string',
            'is_suspended' => 'boolean',
            'suspended_until' => 'date',
            'subscription_tier' => 'string',
            'years_of_experience' => 'integer',
            'practice_areas' => 'array',
            'notification_settings' => 'array',
            'reminder_settings' => 'array',
            'dark_mode' => 'boolean',
        ];
    }

    /**
     * Whether the user is an admin.
     */
    public function isAdmin(): bool
    {
        return $this->role === 'admin';
    }

    /**
     * Whether the user is currently on a paid tier.
     */
    public function isPaid(): bool
    {
        if ($this->subscription_tier !== 'paid') {
            return false;
        }

        if ($this->subscription_expires_at === null) {
            return true;
        }

        return $this->subscription_expires_at->isFuture();
    }

    /**
     * The cases owned by this user.
     */
    public function legalCases(): HasMany
    {
        return $this->hasMany(LegalCase::class, 'user_id');
    }

    /**
     * The device tokens registered by this user.
     */
    public function deviceTokens(): HasMany
    {
        return $this->hasMany(DeviceToken::class);
    }

/**
     * The notification logs for this user.
     */
    public function notificationLogs(): HasMany
    {
        return $this->hasMany(NotificationLog::class);
    }

    /**
     * The payments made by this user.
     */
    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class);
    }
}

