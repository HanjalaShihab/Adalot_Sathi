<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Resources\CaseResource;
use App\Http\Resources\UserResource;
use App\Models\LegalCase;
use App\Models\Payment;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class AdminDashboardController extends Controller
{
    /**
     * Platform-wide statistics for the admin dashboard.
     */
    public function stats(Request $request): JsonResponse
    {
        $totalLawyers = User::where('role', 'lawyer')->count();
        $activeLawyers = User::where('role', 'lawyer')
            ->where('is_suspended', false)
            ->count();
        $pendingVerifications = User::where('role', 'lawyer')
            ->where('verification_status', 'pending')
            ->count();
        $suspendedCount = User::where('role', 'lawyer')
            ->where('is_suspended', true)
            ->count();

        $todayStart = now()->startOfDay();
        $newRegistrations = User::where('role', 'lawyer')
            ->where('created_at', '>=', $todayStart)
            ->count();
        $newRegistrations7d = User::where('role', 'lawyer')
            ->where('created_at', '>=', now()->subDays(7))
            ->count();

        $paidCount = User::where('role', 'lawyer')
            ->where('subscription_tier', 'paid')
            ->where(function ($q) {
                $q->whereNull('subscription_expires_at')
                    ->orWhere('subscription_expires_at', '>=', now()->toDateString());
            })
            ->count();
        $freeCount = User::where('role', 'lawyer')->count() - $paidCount;

        $totalCases = LegalCase::count();
        $activeCases = LegalCase::where('status', 'active')->count();
        $closedCases = LegalCase::where('status', 'closed')->count();
        $onHoldCases = LegalCase::where('status', 'on_hold')->count();

        $totalRevenue = Payment::where('status', 'succeeded')->sum('amount');
        $revenueThisMonth = Payment::where('status', 'succeeded')
            ->where('paid_at', '>=', now()->startOfMonth())
            ->sum('amount');

        return response()->json([
            'data' => [
                'lawyers' => [
                    'total' => $totalLawyers,
                    'active' => $activeLawyers,
                    'suspended' => $suspendedCount,
                ],
                'verifications' => [
                    'pending' => $pendingVerifications,
                ],
                'registrations' => [
                    'today' => $newRegistrations,
                    'last_7_days' => $newRegistrations7d,
                ],
                'subscriptions' => [
                    'free' => $freeCount,
                    'paid' => $paidCount,
                ],
                'cases' => [
                    'total' => $totalCases,
                    'active' => $activeCases,
                    'closed' => $closedCases,
                    'on_hold' => $onHoldCases,
                ],
                'revenue' => [
                    'total' => round((float) $totalRevenue, 2),
                    'this_month' => round((float) $revenueThisMonth, 2),
                    'currency' => 'BDT',
                ],
            ],
        ]);
    }

    /**
     * List all cases across the platform with optional filters.
     */
    public function cases(Request $request): AnonymousResourceCollection
    {
        $query = LegalCase::query()
            ->with(['user', 'deadlines', 'documents'])
            ->withCount('deadlines')
            ->latest();

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->filled('court_name')) {
            $query->where('court_name', 'like', '%' . trim($request->court_name) . '%');
        }

        if ($request->filled('lawyer')) {
            $query->whereHas('user', function ($q) use ($request) {
                $q->where('name', 'like', '%' . trim($request->lawyer) . '%')
                    ->orWhere('email', 'like', '%' . trim($request->lawyer) . '%');
            });
        }

        if ($request->filled('search')) {
            $search = trim($request->search);
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                    ->orWhere('case_number', 'like', "%{$search}%")
                    ->orWhere('client_name', 'like', "%{$search}%");
            });
        }

        if ($request->filled('from')) {
            $query->where('created_at', '>=', $request->from . ' 00:00:00');
        }

        return CaseResource::collection($query->paginate($request->integer('per_page', 20)));
    }

    /**
     * Subscription overview statistics.
     */
    public function subscriptions(Request $request): JsonResponse
    {
        $freeCount = User::where('role', 'lawyer')->where('subscription_tier', 'free')->count();
        $paidCount = User::where('role', 'lawyer')->where('subscription_tier', 'paid')->count();

        $activePaid = User::where('role', 'lawyer')
            ->where('subscription_tier', 'paid')
            ->where(function ($q) {
                $q->whereNull('subscription_expires_at')
                    ->orWhere('subscription_expires_at', '>=', now()->toDateString());
            })
            ->count();
        $expiredPaid = User::where('role', 'lawyer')
            ->where('subscription_tier', 'paid')
            ->where('subscription_expires_at', '<', now()->toDateString())
            ->count();

        // Recent payments.
        $payments = Payment::with('user')
            ->latest('paid_at')
            ->limit(20)
            ->get()
            ->map(fn (Payment $p) => [
                'id' => $p->id,
                'user' => $p->user?->name,
                'email' => $p->user?->email,
                'amount' => round((float) $p->amount, 2),
                'currency' => $p->currency,
                'method' => $p->method,
                'status' => $p->status,
                'reference' => $p->reference,
                'paid_at' => $p->paid_at?->toIso8601String(),
                'description' => $p->description,
            ]);

        return response()->json([
            'data' => [
                'summary' => [
                    'free' => $freeCount,
                    'paid' => $paidCount,
                    'active_paid' => $activePaid,
                    'expired_paid' => $expiredPaid,
                ],
                'recent_payments' => $payments,
            ],
        ]);
    }

    /**
     * List all lawyers (for admin users screen).
     */
    public function lawyers(Request $request): AnonymousResourceCollection
    {
        return User::where('role', 'lawyer')
            ->withCount('legalCases')
            ->latest()
            ->paginate($request->integer('per_page', 20))
            ->through(fn (User $u) => new UserResource($u));
    }
}
