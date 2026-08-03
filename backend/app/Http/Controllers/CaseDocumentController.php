<?php

namespace App\Http\Controllers;

use App\Models\CaseDocument;
use App\Models\LegalCase;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use RuntimeException;
use Symfony\Component\HttpFoundation\StreamedResponse;

class CaseDocumentController extends Controller
{
    /**
     * List all documents attached to a case.
     */
    public function index(Request $request, int $caseId): JsonResponse
    {
        $legalCase = $this->findCase($request->user()->id, $caseId);

        return response()->json([
            'data' => $legalCase->documents()->latest()->get()->map(fn ($d) => [
                'id' => $d->id,
                'file_name' => $d->file_name,
                'file_path' => $d->file_path,
                'mime_type' => $d->mime_type,
                'size' => $d->size,
                'type' => $d->type,
                'created_at' => $d->created_at?->toIso8601String(),
            ]),
        ]);
    }

    /**
     * Upload a document to a case.
     */
    public function store(Request $request, int $caseId): JsonResponse
    {
        $legalCase = $this->findCase($request->user()->id, $caseId);

        $request->validate([
            'file' => ['required', 'file', 'max:20480'],
            'type' => ['sometimes', 'string', 'in:pdf,image,word'],
        ]);

        $file = $request->file('file');
        if (! $file) {
            throw new RuntimeException('No file was uploaded.');
        }

        // Determine document type from mime/content if not explicitly provided.
        $type = $request->input('type');
        if (! $type) {
            $mime = $file->getMimeType() ?? '';
            $type = match (true) {
                str_contains($mime, 'image/') => 'image',
                str_contains($mime, 'pdf') => 'pdf',
                str_contains($mime, 'msword'),
                str_contains($mime, 'wordprocessingml') => 'word',
                default => 'pdf',
            };
        }

        $extension = $file->getClientOriginalExtension() ?: 'bin';
        $storedPath = $file->storeAs(
            'case-documents/' . $caseId,
            Str::uuid() . '.' . $extension,
            'local',
        );

        $document = $legalCase->documents()->create([
            'file_name' => $file->getClientOriginalName(),
            'file_path' => $storedPath,
            'mime_type' => $file->getMimeType(),
            'size' => $file->getSize(),
            'type' => $type,
        ]);

        return response()->json([
            'message' => 'Document uploaded successfully.',
            'data' => [
                'id' => $document->id,
                'file_name' => $document->file_name,
                'file_path' => $document->file_path,
                'mime_type' => $document->mime_type,
                'size' => $document->size,
                'type' => $document->type,
                'created_at' => $document->created_at?->toIso8601String(),
            ],
        ], 201);
    }

    /**
     * Download a document.
     */
    public function download(Request $request, int $caseId, int $documentId): StreamedResponse|JsonResponse
    {
        $document = $this->findDocument($request->user()->id, $caseId, $documentId);

        if (! Storage::disk('local')->exists($document->file_path)) {
            return response()->json([
                'message' => 'Document file is missing on the server.',
            ], 404);
        }

        return Storage::disk('local')->download($document->file_path, $document->file_name);
    }

    /**
     * Delete a document.
     */
    public function destroy(Request $request, int $caseId, int $documentId): JsonResponse
    {
        $document = $this->findDocument($request->user()->id, $caseId, $documentId);

        Storage::disk('local')->delete($document->file_path);
        $document->delete();

        return response()->json([
            'message' => 'Document deleted successfully.',
        ]);
    }

    /**
     * Find a case owned by the given user.
     */
    private function findCase(int $userId, int $caseId): LegalCase
    {
        return LegalCase::query()
            ->where('id', $caseId)
            ->where('user_id', $userId)
            ->firstOrFail();
    }

    /**
     * Find a document belonging to a user's case.
     */
    private function findDocument(int $userId, int $caseId, int $documentId): CaseDocument
    {
        return CaseDocument::query()
            ->where('id', $documentId)
            ->where('case_id', $caseId)
            ->whereHas('case', function ($q) use ($userId) {
                $q->where('user_id', $userId);
            })
            ->firstOrFail();
    }
}
