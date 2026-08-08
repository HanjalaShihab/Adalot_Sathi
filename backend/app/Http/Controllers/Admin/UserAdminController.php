<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class UserAdminController extends Controller
{
    /**
     * List all users (super admin). Optionally filter by role/tier.
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = User::query()->withCount('legalCases');

        if ($request->filled('role')) {
            $query->where('role', $request->role);
        }

        if ($request->filled('subscription_tier')) {
            $query->where('subscription_tier', $request->subscription_tier);
        }

        if ($request->filled('search')) {
            $search = trim($request->search);
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('email', 'like', "%{$search}%")
                    ->orWhere('phone', 'like', "%{$search}%");
            });
        }

        return UserResource::collection($query->paginate($request->integer('per_page', 20)));
    }

    /**
     * Show a single user (super admin).
     */
    public function show(int $id): UserResource
    {
        return new UserResource(User::withCount('legalCases')->findOrFail($id));
    }

    /**
     * Update a user's role or subscription (super admin).
     */
    public function update(Request $request, int $id): UserResource
    {
        $user = User::findOrFail($id);

        $validated = $request->validate([
            'role' => ['sometimes', 'string', Rule::in(['lawyer', 'admin'])],
            'subscription_tier' => ['sometimes', 'string', Rule::in(['free', 'paid'])],
            'subscription_expires_at' => ['nullable', 'date', 'date_format:Y-m-d'],
        ]);

        // Guard against removing the last admin.
        if (
            isset($validated['role'])
            && $validated['role'] === 'lawyer'
            && $user->role === 'admin'
            && User::where('role', 'admin')->count() === 1
        ) {
            throw ValidationException::withMessages([
                'role' => 'You cannot demote the last remaining admin.',
            ]);
        }

        $user->update($validated);

        return new UserResource($user->fresh()->loadCount('legalCases'));
    }

/**
     * Verify a lawyer's account (approve pending verification).
     */
    public function verify(int $id): UserResource
    {
        $user = User::findOrFail($id);

        $user->update([
            'verification_status' => 'verified',
            'rejection_reason' => null,
        ]);

        return new UserResource($user->fresh()->loadCount('legalCases'));
    }

    /**
     * Reject a lawyer's verification request with a reason.
     */
    public function reject(Request $request, int $id): UserResource
    {
        $user = User::findOrFail($id);

        $validated = $request->validate([
            'reason' => ['required', 'string', 'max:1000'],
        ]);

        $user->update([
            'verification_status' => 'rejected',
            'rejection_reason' => $validated['reason'],
        ]);

        return new UserResource($user->fresh()->loadCount('legalCases'));
    }

    /**
     * Suspend or unsuspend a lawyer's account.
     */
    public function suspend(Request $request, int $id): UserResource
    {
        $user = User::findOrFail($id);

        if ($user->role === 'admin' && $user->id === $request->user()->id) {
            throw ValidationException::withMessages([
                'user' => 'You cannot suspend your own account.',
            ]);
        }

        $validated = $request->validate([
            'is_suspended' => ['required', 'boolean'],
            'suspended_until' => ['nullable', 'date', 'date_format:Y-m-d'],
        ]);

        $user->update([
            'is_suspended' => (bool) $validated['is_suspended'],
            'suspended_until' => $validated['suspended_until'] ?? null,
        ]);

        return new UserResource($user->fresh()->loadCount('legalCases'));
    }

    /**
     * Deactivate a user account (super admin).
     */
    public function destroy(int $id): JsonResponse
    {
        $user = User::findOrFail($id);

        if ($user->role === 'admin' && User::where('role', 'admin')->count() === 1) {
            throw ValidationException::withMessages([
                'user' => 'You cannot delete the last remaining admin.',
            ]);
        }

        $user->delete();

        return response()->json([
            'message' => 'User account deleted successfully.',
        ]);
    }
}

