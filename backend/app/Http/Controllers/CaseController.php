<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreCaseRequest;
use App\Http\Requests\UpdateCaseRequest;
use App\Http\Resources\CaseResource;
use App\Models\LegalCase;
use App\Services\CaseLimitService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use RuntimeException;

class CaseController extends Controller
{
    public function __construct(
        private readonly CaseLimitService $caseLimitService,
    ) {
    }

    /**
     * List the authenticated user's cases, with optional search + status filter.
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = $request->user()->legalCases()
            ->with(['deadlines', 'documents'])
            ->latest();

        // Search by case number or client name.
        if ($request->filled('search')) {
            $search = trim($request->search);
            $query->where(function ($q) use ($search) {
                $q->where('case_number', 'like', "%{$search}%")
                    ->orWhere('client_name', 'like', "%{$search}%")
                    ->orWhere('title', 'like', "%{$search}%");
            });
        }

        // Filter by status.
        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        return CaseResource::collection($query->paginate($request->integer('per_page', 20)));
    }

    /**
     * Store a newly created case.
     */
    public function store(StoreCaseRequest $request): JsonResponse
    {
        $user = $request->user();

        // Enforce free-tier active case limit.
        $newStatus = $request->input('status', 'active');

        if ($newStatus === 'active') {
            try {
                $this->caseLimitService->assertCanCreateActiveCase($user);
            } catch (RuntimeException $e) {
                return response()->json([
                    'error' => 'case_limit_reached',
                    'message' => $e->getMessage(),
                    'limit' => CaseLimitService::FREE_TIER_MAX_ACTIVE_CASES,
                ], 403);
            }
        }

        $legalCase = $user->legalCases()->create($request->validated());

        return (new CaseResource($legalCase->load(['deadlines', 'documents'])))
            ->response()
            ->setStatusCode(201);
    }

    /**
     * Display the specified case.
     */
    public function show(Request $request, int $id): CaseResource
    {
        $legalCase = $request->user()->legalCases()
            ->with(['deadlines', 'documents'])
            ->findOrFail($id);

        return new CaseResource($legalCase);
    }

    /**
     * Update the specified case.
     */
    public function update(UpdateCaseRequest $request, int $id): CaseResource
    {
        $user = $request->user();
        $legalCase = $user->legalCases()->findOrFail($id);

        // If the user is moving a non-active case to active, enforce the limit.
        $newStatus = $request->input('status', $legalCase->status);
        if ($newStatus === 'active' && $legalCase->status !== 'active') {
            try {
                $this->caseLimitService->assertCanCreateActiveCase($user);
            } catch (RuntimeException $e) {
                abort(403, $e->getMessage());
            }
        }

        $legalCase->update($request->validated());

        return new CaseResource($legalCase->load(['deadlines', 'documents']));
    }

    /**
     * Remove the specified case.
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $legalCase = $request->user()->legalCases()->findOrFail($id);
        $legalCase->delete();

        return response()->json([
            'message' => 'Case deleted successfully.',
        ]);
    }
}
