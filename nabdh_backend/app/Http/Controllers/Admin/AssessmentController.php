<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AssessmentItem;
use App\Models\AssessmentSection;
use App\Models\AssessmentTemplate;
use App\Models\PatientReport;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

/**
 * Assessment library: sections (ROM, MMT…), their items, and templates.
 * Reports keep a copy of names/ranges, so edits here never alter saved reports.
 */
class AssessmentController extends Controller
{
    public function index()
    {
        return view('admin.assessments.index', [
            'templates'    => AssessmentTemplate::withCount('sections')->orderBy('sort')->orderBy('id')->get(),
            'sections'     => AssessmentSection::withCount('items')->orderBy('sort')->orderBy('id')->get(),
            'types'        => AssessmentSection::TYPES,
            'reportsCount' => PatientReport::count(),
        ]);
    }

    // ── Sections ─────────────────────────────────────────────

    private function sectionRules(): array
    {
        return [
            'name_en'   => 'required|string|max:150',
            'name_ar'   => 'required|string|max:150',
            'type'      => ['required', Rule::in(array_keys(AssessmentSection::TYPES))],
            'unit'      => 'nullable|string|max:20',
            'scale_min' => 'nullable|numeric|min:-1000|max:1000',
            'scale_max' => 'nullable|numeric|min:-1000|max:1000|gte:scale_min',
            'sort'      => 'nullable|integer|min:0|max:9999',
        ];
    }

    public function storeSection(Request $request)
    {
        $data = $request->validate($this->sectionRules());
        $data['sort'] ??= (int) AssessmentSection::max('sort') + 1;
        $section = AssessmentSection::create($data);
        return redirect()->route('admin.assessments.sections.edit', $section)->with('success', 'تمت إضافة التصنيف — أضف البنود الآن');
    }

    public function editSection(AssessmentSection $section)
    {
        return view('admin.assessments.section', [
            'section' => $section->load('items'),
            'types'   => AssessmentSection::TYPES,
        ]);
    }

    public function updateSection(Request $request, AssessmentSection $section)
    {
        $data = $request->validate($this->sectionRules() + ['is_active' => 'nullable|boolean']);
        $data['is_active'] = $request->boolean('is_active');
        $data['sort'] ??= $section->sort;
        $section->update($data);
        return back()->with('success', 'تم حفظ التصنيف');
    }

    public function destroySection(AssessmentSection $section)
    {
        $section->delete();
        return redirect()->route('admin.assessments.index')->with('success', 'تم حذف التصنيف (التقارير المحفوظة لا تتأثر)');
    }

    // ── Items ────────────────────────────────────────────────

    private function itemRules(): array
    {
        return [
            'name_en'    => 'required|string|max:150',
            'name_ar'    => 'nullable|string|max:150',
            'normal_min' => 'nullable|numeric|min:-1000|max:1000',
            'normal_max' => 'nullable|numeric|min:-1000|max:1000|gte:normal_min',
            'sort'       => 'nullable|integer|min:0|max:9999',
        ];
    }

    public function storeItem(Request $request, AssessmentSection $section)
    {
        $data = $request->validate($this->itemRules());
        $data['sort'] ??= (int) $section->items()->max('sort') + 1;
        $section->items()->create($data);
        return back()->with('success', 'تمت إضافة البند');
    }

    public function updateItem(Request $request, AssessmentItem $item)
    {
        $data = $request->validate($this->itemRules());
        $data['sort'] ??= $item->sort;
        $data['is_active'] = $request->boolean('is_active');
        $item->update($data);
        return back()->with('success', 'تم حفظ البند');
    }

    public function destroyItem(AssessmentItem $item)
    {
        $item->delete();
        return back()->with('success', 'تم حذف البند (التقارير المحفوظة لا تتأثر)');
    }

    // ── Templates ────────────────────────────────────────────

    public function storeTemplate(Request $request)
    {
        $data = $request->validate([
            'name_en'     => 'required|string|max:150',
            'name_ar'     => 'required|string|max:150',
            'description' => 'nullable|string|max:255',
        ]);
        $data['sort'] = (int) AssessmentTemplate::max('sort') + 1;
        $template = AssessmentTemplate::create($data);
        return redirect()->route('admin.assessments.templates.edit', $template)->with('success', 'تمت إضافة القالب — اختر أقسامه');
    }

    public function editTemplate(AssessmentTemplate $template)
    {
        return view('admin.assessments.template', [
            'template' => $template->load('sections'),
            'sections' => AssessmentSection::withCount('items')->orderBy('sort')->orderBy('id')->get(),
            'types'    => AssessmentSection::TYPES,
        ]);
    }

    public function updateTemplate(Request $request, AssessmentTemplate $template)
    {
        $data = $request->validate([
            'name_en'       => 'required|string|max:150',
            'name_ar'       => 'required|string|max:150',
            'description'   => 'nullable|string|max:255',
            'sort'          => 'nullable|integer|min:0|max:9999',
            'sections'      => 'nullable|array',
            'sections.*'    => 'integer|exists:assessment_sections,id',
            'order'         => 'nullable|array',
            'order.*'       => 'nullable|integer|min:0|max:9999',
        ]);

        $template->update([
            'name_en'     => $data['name_en'],
            'name_ar'     => $data['name_ar'],
            'description' => $data['description'] ?? null,
            'sort'        => $data['sort'] ?? $template->sort,
            'is_active'   => $request->boolean('is_active'),
        ]);

        $order = $data['order'] ?? [];
        $template->sections()->sync(collect($data['sections'] ?? [])->mapWithKeys(
            fn ($id) => [(int) $id => ['sort' => (int) ($order[$id] ?? 0)]]
        )->all());

        return back()->with('success', 'تم حفظ القالب');
    }

    public function destroyTemplate(AssessmentTemplate $template)
    {
        $template->delete();
        return redirect()->route('admin.assessments.index')->with('success', 'تم حذف القالب (التقارير المحفوظة لا تتأثر)');
    }
}
