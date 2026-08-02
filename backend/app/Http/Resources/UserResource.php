<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use App\Services\CaseLimitService;

class UserResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $caseLimitService = app(CaseLimitService::class);

        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'phone' => $this->phone,
            'role' => $this->role,
            'subscription_tier' => $this->subscription_tier,
            'subscription_expires_at' => $this->subscription_expires_at?->format('Y-m-d'),
            'subscription' => [
                'tier' => $this->subscription_tier,
                'is_paid' => $this->isPaid(),
                'active_case_limit' => $this->isPaid()
                    ? null
                    : CaseLimitService::FREE_TIER_MAX_ACTIVE_CASES,
                'active_cases_count' => $this->legalCases()
                    ->where('status', 'active')
                    ->count(),
                'remaining_active_slots' => $caseLimitService->remainingActiveCaseSlots($this->resource),
            ],
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];
    }
}

