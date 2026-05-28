<?php

namespace App\Http\Controllers\Patient;

use App\Http\Controllers\Controller;
use App\Models\PatientDocument;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class DocumentController extends Controller
{
    /** List all documents for the authenticated patient */
    public function index(Request $request): JsonResponse
    {
        $patient = $request->user()->patient;
        $docs = PatientDocument::where('patient_id', $patient->id)
            ->orderByDesc('document_date')
            ->orderByDesc('created_at')
            ->get()
            ->append('type_label');

        return response()->json($docs);
    }

    /** Upload a new document */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'title'         => 'required|string|max:255',
            'type'          => 'required|in:diagnosis,report,prescription,scan,lab,other',
            'file'          => 'nullable|file|max:20480', // 20 MB
            'notes'         => 'nullable|string|max:2000',
            'doctor_name'   => 'nullable|string|max:255',
            'document_date' => 'nullable|date',
        ]);

        $patient = $request->user()->patient;

        $fileUrl  = null;
        $fileName = null;
        $fileMime = null;

        if ($request->hasFile('file')) {
            $file     = $request->file('file');
            $path     = $file->store('patient-documents', 'public');
            $fileUrl  = Storage::disk('public')->url($path);
            $fileName = $file->getClientOriginalName();
            $fileMime = $file->getMimeType();
        }

        $doc = PatientDocument::create([
            'patient_id'    => $patient->id,
            'title'         => $request->title,
            'type'          => $request->type,
            'file_url'      => $fileUrl,
            'file_name'     => $fileName,
            'file_mime'     => $fileMime,
            'notes'         => $request->notes,
            'doctor_name'   => $request->doctor_name,
            'document_date' => $request->document_date,
        ]);

        return response()->json($doc->append('type_label'), 201);
    }

    /** Delete a document */
    public function destroy(Request $request, PatientDocument $document): JsonResponse
    {
        $patient = $request->user()->patient;
        abort_if($document->patient_id !== $patient->id, 403);

        // Delete file from storage if exists
        if ($document->file_url) {
            $path = str_replace(Storage::disk('public')->url(''), '', $document->file_url);
            Storage::disk('public')->delete($path);
        }

        $document->delete();
        return response()->json(['ok' => true]);
    }
}
