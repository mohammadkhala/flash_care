<?php

namespace App\Http\Controllers\Therapist;

use App\Http\Controllers\Controller;
use App\Models\AssessmentTemplate;
use App\Models\PatientReport;
use App\Services\ReportPdfService;
use App\Services\ReportService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class ReportController extends Controller
{
    public function __construct(private ReportService $reports) {}

    private function therapistId(Request $request): int
    {
        return $request->user()->therapist->id;
    }

    private function own(Request $request, PatientReport $report): void
    {
        abort_if($report->therapist_id !== $this->therapistId($request), 403);
    }

    /** Active templates with their sections and items (what the doctor fills). */
    public function templates(): JsonResponse
    {
        $templates = AssessmentTemplate::where('is_active', true)->orderBy('sort')->orderBy('id')->get()
            ->map(fn ($t) => [
                'id'          => $t->id,
                'name_en'     => $t->name_en,
                'name_ar'     => $t->name_ar,
                'description' => $t->description,
                'sections'    => $this->reports->structure($t),
            ])
            ->filter(fn ($t) => count($t['sections']) > 0)
            ->values();

        return response()->json($templates);
    }

    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'client_id' => 'nullable|integer',
            'search'    => 'nullable|string|max:100',
        ]);

        $reports = PatientReport::with(['client', 'clinic'])
            ->where('therapist_id', $this->therapistId($request))
            ->when($request->filled('client_id'), fn ($q) => $q->where('client_id', $request->client_id))
            ->when($request->filled('search'), function ($q) use ($request) {
                $s = trim($request->search);
                $q->where(fn ($w) => $w->where('title', 'like', "%{$s}%")
                    ->orWhereHas('client', fn ($c) => $c->where('name', 'like', "%{$s}%")));
            })
            ->orderByDesc('assessed_at')->orderByDesc('id')
            ->limit(200)
            ->get();

        return response()->json($reports->map(fn ($r) => $this->reports->format($r, false))->values());
    }

    public function show(Request $request, PatientReport $report): JsonResponse
    {
        $this->own($request, $report);
        return response()->json($this->reports->format($report->load(['client', 'clinic'])));
    }

    private function rules(Request $request, bool $creating): array
    {
        $tid = $this->therapistId($request);
        return [
            'client_id'      => [$creating ? 'required' : 'prohibited', Rule::exists('finance_clients', 'id')
                ->where('therapist_id', $tid)->whereNull('deleted_at')],
            'template_id'    => [$creating ? 'required' : 'prohibited', Rule::exists('assessment_templates', 'id')
                ->where('is_active', true)],
            'clinic_id'      => ['nullable', Rule::exists('clinics', 'id')->where('therapist_id', $tid)],
            'appointment_id' => ['nullable', Rule::exists('appointments', 'id')->where('therapist_id', $tid)],
            'title'          => ['nullable', 'string', 'max:255'],
            'report_type'    => ['nullable', Rule::in(array_keys(PatientReport::TYPES))],
            'referral_source'=> ['nullable', Rule::in(array_keys(PatientReport::REFERRALS))],
            'referral_name'  => ['nullable', 'string', 'max:255'],
            'medical_diagnosis' => ['nullable', 'string', 'max:500'],
            'sessions_per_week' => ['nullable', 'integer', 'min:1', 'max:14'],
            'plan_weeks'     => ['nullable', 'integer', 'min:1', 'max:104'],
            'assessed_at'    => [$creating ? 'required' : 'sometimes', 'date'],
            'values'         => ['nullable', 'array'],
            'section_notes'  => ['nullable', 'array'],
            'notes'          => ['nullable', 'string', 'max:5000'],
            'status'         => ['nullable', 'in:draft,final'],
        ];
    }

    private const HEADER_FIELDS = [
        'report_type', 'referral_source', 'referral_name', 'medical_diagnosis', 'sessions_per_week', 'plan_weeks',
    ];

    /** A final report is an official document: the practice license number must be on it. */
    private function ensureCanFinalize(Request $request): void
    {
        if ($request->input('status') !== 'final') return;
        if (blank($request->user()->therapist->license_number)) {
            throw \Illuminate\Validation\ValidationException::withMessages([
                'license_number' => 'أضف رقم إجازة مزاولة المهنة في ملفك الشخصي أولاً (يظهر في الترويسة وتحت التوقيع). يمكنك حفظ مسودة الآن.',
            ]);
        }
    }

    public function store(Request $request): JsonResponse
    {
        $request->validate($this->rules($request, true));
        $this->ensureCanFinalize($request);

        $template = AssessmentTemplate::findOrFail($request->template_id);
        $sections = $this->reports->applyValues(
            $this->reports->structure($template),
            $request->input('values', []),
            $request->input('section_notes', []),
        );
        $tid = $this->therapistId($request);
        $status = $request->input('status', 'draft');

        $report = \Illuminate\Support\Facades\DB::transaction(fn () => PatientReport::create([
            'therapist_id'   => $tid,
            'number'         => (int) PatientReport::withTrashed()->where('therapist_id', $tid)->lockForUpdate()->max('number') + 1,
            'client_id'      => $request->client_id,
            'clinic_id'      => $request->clinic_id,
            'template_id'    => $template->id,
            'appointment_id' => $request->appointment_id,
            'title'          => $request->filled('title') ? $request->title : $template->name_en,
            'assessed_at'    => $request->assessed_at,
            'data'           => ['sections' => $sections],
            'notes'          => $request->notes,
            'status'         => $status,
            'finalized_at'   => $status === 'final' ? now() : null,
            ...$request->only(self::HEADER_FIELDS),
            'report_type'    => $request->input('report_type') ?? 'initial',
        ]));

        return response()->json($this->reports->format($report->load(['client', 'clinic'])), 201);
    }

    public function update(Request $request, PatientReport $report): JsonResponse
    {
        $this->own($request, $report);
        $request->validate($this->rules($request, false));
        $this->ensureCanFinalize($request);

        $fields = $request->only(['clinic_id', 'appointment_id', 'title', 'assessed_at', 'notes', 'status', ...self::HEADER_FIELDS]);
        if (array_key_exists('report_type', $fields) && blank($fields['report_type'])) unset($fields['report_type']);
        if (($fields['status'] ?? null) === 'final' && !$report->finalized_at) $fields['finalized_at'] = now();
        if ($request->has('values') || $request->has('section_notes')) {
            $fields['data'] = ['sections' => $this->reports->applyValues(
                $report->data['sections'] ?? [],
                $request->input('values', []),
                $request->input('section_notes', []),
            )];
        }
        if (array_key_exists('title', $fields) && blank($fields['title'])) unset($fields['title']);

        $report->update($fields);

        return response()->json($this->reports->format($report->fresh(['client', 'clinic'])));
    }

    public function destroy(Request $request, PatientReport $report): JsonResponse
    {
        $this->own($request, $report);
        $report->delete();
        return response()->json(['ok' => true]);
    }

    public function pdf(Request $request, PatientReport $report, ReportPdfService $pdf): Response
    {
        $this->own($request, $report);

        $name = Str::slug(($report->client?->code_label ?? 'report') . ' ' . ($report->number_label ?? '') . ' ' . $report->title) . '.pdf';

        return response($pdf->render($report), 200, [
            'Content-Type'        => 'application/pdf',
            'Content-Disposition' => 'inline; filename="' . $name . '"',
        ]);
    }
}
