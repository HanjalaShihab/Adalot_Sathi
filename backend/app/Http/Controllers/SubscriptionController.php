<?php

namespace App\Http\Controllers;

use App\Http\Resources\UserResource;
use App\Models\Payment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class SubscriptionController extends Controller
{
    /**
     * Upgrade the authenticated user to the paid (Pro) tier.
     */
    public function upgrade(Request $request): JsonResponse
    {
        $user = $request->user();

        // Simulate a successful payment (no real gateway wired up yet).
        $payment = Payment::create([
            'user_id' => $user->id,
            'reference' => 'PAY-' . strtoupper(Str::random(10)),
            'method' => 'card',
            'status' => 'succeeded',
            'amount' => 999,
            'currency' => 'BDT',
            'description' => 'Adalot Sathi Plus — annual subscription',
            'paid_at' => now(),
        ]);

        $user->update([
            'subscription_tier' => 'paid',
            'subscription_expires_at' => now()->addYear()->toDateString(),
        ]);

        return response()->json([
            'message' => 'Welcome to Adalot Sathi Plus! Your subscription is now active.',
            'payment' => [
                'id' => $payment->id,
                'reference' => $payment->reference,
                'amount' => round((float) $payment->amount, 2),
                'currency' => $payment->currency,
                'paid_at' => $payment->paid_at?->toIso8601String(),
            ],
            'user' => new UserResource($user->fresh()),
        ]);
    }

    /**
     * Cancel the authenticated user's paid subscription.
     */
    public function cancel(Request $request): JsonResponse
    {
        $user = $request->user();

        if ($user->subscription_tier !== 'paid') {
            return response()->json([
                'message' => 'You do not have an active paid subscription.',
            ], 200);
        }

        $user->update([
            'subscription_tier' => 'free',
            'subscription_expires_at' => null,
        ]);

        return response()->json([
            'message' => 'Your subscription has been cancelled.',
            'user' => new UserResource($user->fresh()),
        ]);
    }

/**
     * Payment history for the authenticated user.
     */
    public function payments(Request $request): JsonResponse
    {
        $payments = $request->user()
            ->payments()
            ->latest('paid_at')
            ->paginate($request->integer('per_page', 20));

        return response()->json([
            'data' => $payments->map(fn (Payment $p) => [
                'id' => $p->id,
                'reference' => $p->reference,
                'amount' => round((float) $p->amount, 2),
                'currency' => $p->currency,
                'method' => $p->method,
                'status' => $p->status,
                'description' => $p->description,
                'paid_at' => $p->paid_at?->toIso8601String(),
            ])->values(),
            'meta' => [
                'current_page' => $payments->currentPage(),
                'last_page' => $payments->lastPage(),
                'total' => $payments->total(),
            ],
        ]);
    }
}
