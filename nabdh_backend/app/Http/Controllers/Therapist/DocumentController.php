<?php

namespace App\Http\Controllers\Therapist;

use App\Http\Controllers\Controller;
use App\Models\TherapistDocument;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class DocumentController extends Controller
{
    /** GET /therapist/documents */
    public function index(Request $r)
    {
        $docs = $r->user()->therapist
            ->documents()
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json(['documents' => $docs]);
    }

    /**
     * POST /therapist/documents
     * Upload a single document (PDF / image).
     * Accepts multipart/form-data: file, type, label
     */
    public function store(Request $r)
    {
        $r->validate([
            'file'  => 'required|file|mimes:pdf,jpg,jpeg,png|max:10240', // 10 MB
            'type'  => 'required|in:cv,license,certificate,other',
            'label' => 'nullable|string|max:120',
        ]);

        $therapist = $r->user()->therapist;

        $uploaded = $r->file('file');
        $path     = $uploaded->store("therapist_docs/{$therapist->id}", 'public');
        $sizeKb   = $uploaded->getSize();
        $sizeFmt  = $sizeKb < 1024 * 1024
            ? round($sizeKb / 1024, 1) . ' KB'
            : round($sizeKb / (1024 * 1024), 1) . ' MB';

        $doc = TherapistDocument::create([
            'therapist_id' => $therapist->id,
            'type'         => $r->type,
            'file_path'    => $path,
            'file_name'    => $uploaded->getClientOriginalName(),
            'file_size'    => $sizeFmt,
            'label'        => $r->label ?? TherapistDocument::$typeLabels[$r->type] ?? $r->type,
        ]);

        return response()->json(['document' => $doc], 201);
    }

    /** DELETE /therapist/documents/{document} */
    public function destroy(Request $r, TherapistDocument $document)
    {
        // Ownership check
        if ($document->therapist_id !== $r->user()->therapist?->id) {
            abort(403);
        }

        Storage::disk('public')->delete($document->file_path);
        $document->delete();

        return response()->json(['message' => 'تم الحذف']);
    }
}
