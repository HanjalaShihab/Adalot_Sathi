<?php

namespace App\Services;

use App\Models\LegalCase;
use App\Models\User;
use RuntimeException;

class CaseLimitService
{
    /**
     * The maximum number of active cases allowed on the free tier.
     */
    public const FREE_TIER_MAX_ACTIVE_CASES = 5;

    /**
     * Assert that the given user is allowed to create a new active case.
     *
     * @throws RuntimeException When the user exceeds the free-tier active case limit.
     */
    public function assertCanCreateActiveCase(User $user): void
    {
        if ($user->isPaid()) {
            return;
        }

        $activeCount = $user->legalCases()
            ->where('status', LegalCase::STATUS_ACTIVE)
            ->count();

        if ($activeCount >= self::FREE_TIER_MAX_ACTIVE_CASES) {
            throw new RuntimeException(
                'You have reached the free plan limit of '
                .self::FREE_TIER_MAX_ACTIVE_CASES
                .' active cases. Upgrade to Adalot Sathi Plus for unlimited cases and SMS reminders.',
            );
        }
    }

    /**
     * Determine whether a user has reached the free-tier active case limit.
     */
    public function hasReachedActiveCaseLimit(User $user): bool
    {
        if ($user->isPaid()) {
            return false;
        }

        return $user->legalCases()
            ->where('status', LegalCase::STATUS_ACTIVE)
            ->count() >= self::FREE_TIER_MAX_ACTIVE_CASES;
    }

    /**
     * The number of active cases remaining before the free-tier limit is reached.
     */
    public function remainingActiveCaseSlots(User $user): int
    {
        if ($user->isPaid()) {
            return PHP_INT_MAX;
        }

        $activeCount = $user->legalCases()
            ->where('status', LegalCase::STATUS_ACTIVE)
            ->count();

        return max(0, self::FREE_TIER_MAX_ACTIVE_CASES - $activeCount);
    }
}

