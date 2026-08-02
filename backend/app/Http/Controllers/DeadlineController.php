<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreDeadlineRequest;
use App\Http\Requests\UpdateDeadlineRequest;
use App\Http\Resources\DeadlineResource;
use App\Models\Deadline;
use App\Models\LegalCase;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class DeadlineController extends Controller
{
    /**
     * List deadlines for a given case.
     */
    public function index(Request $request, int $caseId): AnonymousResourceCollection
    {
        $legalCase = $request->user()->legalCases()->findOrFail($caseId);

        $query = $legalCase->deadlines();

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        return DeadlineResource::collection(
            $query->orderBy('due_date')->orderBy('due_time')->get(),
        );
    }

    /**
     * Store a new deadline under a case.
     */
    public function store(StoreDeadlineRequest $request, int $caseId): JsonResponse
    {
        $legalCase = $request->user()->legalCases()->findOrFail($caseId);

        $deadline = $legalCase->deadlines()->create($request->validated());

        return (new DeadlineResource($deadline))
            ->response()
            ->setStatusCode(201);
    }

    /**
     * Display a single deadline.
     */
    public function show(Request $request, int $caseId, int $id): DeadlineResource
    {
        $deadline = $this->findDeadline($request->user()->id, $caseId, $id);

        return new DeadlineResource($deadline);
    }

    /**
     * Update a deadline.
     */
    public function update(UpdateDeadlineRequest $request, int $caseId, int $id): DeadlineResource
    {
        $deadline = $this->findDeadline($request->user()->id, $caseId, $id);
        $deadline->update($request->validated());

        return new DeadlineResource($deadline->fresh());
    }

    /**
     * Delete a deadline.
     */
    public function destroy(Request $request, int $caseId, int $id): JsonResponse
    {
        $deadline = $this->findDeadline($request->user()->id, $caseId, $id);
        $deadline->delete();

        return response()->json([
            'message' => 'Deadline deleted successfully.',
        ]);
    }

    /**
     * Mark a deadline as completed.
     */
    public function markCompleted(Request $request, int $caseId, int $id): DeadlineResource
    {
        $deadline = $this->findDeadline($request->user()->id, $caseId, $id);
        $deadline->update(['status' => 'completed']);

        return new DeadlineResource($deadline->fresh());
    }

    /**
     * Upcoming deadlines across all of the user's cases, sorted by due date ascending.
     * Supports from/to date-range query params.
     */
    public function upcoming(Request $request): AnonymousResourceCollection
    {
        $user = $request->user();

        $query = Deadline::query()
            ->whereHas('case', function ($q) use ($user) {
                $q->where('user_id', $user->id);
            })
            ->where('status', '!=', 'completed')
            ->orderBy('due_date')
            ->orderBy('due_time');

        if ($request->filled('from')) {
            $query->where('due_date', '>=', $request->date('from'));
        }

        if ($request->filled('to')) {
            $query->where('due_date', '<=', $request->date('to'));
        }

        // Optionally filter by event type.
        if ($request->filled('event_type')) {
            $query->where('event_type', $request->event_type);
        }

        $limit = $request->integer('limit', 100);

        return DeadlineResource::collection($query->with('case:id,title,case_number,client_name')->limit($limit)->get());
    }

    /**
     * Find a deadline belonging to a user's case.
     */
    private function findDeadline(int $userId, int $caseId, int $id): Deadline
    {
        return Deadline::query()
            ->where('id', $id)
            ->where('case_id', $caseId)
            ->whereHas('case', function ($q) use ($userId) {
                $q->where('user_id', $userId);
            })
            ->firstOrFail();
    }
}

