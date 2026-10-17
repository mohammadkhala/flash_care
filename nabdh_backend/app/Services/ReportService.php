<?php

namespace App\Services;

use App\Models\AssessmentTemplate;
use App\Models\PatientReport;
use Illuminate\Validation\ValidationException;

/**
 * Report `data` = { sections: [ { id, name_en, name_ar, type, unit, scale_min, scale_max, notes,
 *   items: [ { id, name_en, name_ar, normal_min, normal_max, right, left, value, text, abnormal } ] } ] }
 * Names and normal ranges are copied from the template when the report is created.
 */
class ReportService
{
    /** Active sections/items of a template, as sent to the app and copied into new reports. */
    public function structure(AssessmentTemplate $template): array
    {
        $template->loadMissing(['sections' => fn ($q) => $q->where('is_active', true), 'sections.items']);

        return $template->sections->map(fn ($s) => [
            'id'        => $s->id,
            'name_en'   => $s->name_en,
            'name_ar'   => $s->name_ar,
            'type'      => $s->type,
            'unit'      => $s->unit,
            'scale_min' => $s->scale_min,
            'scale_max' => $s->scale_max,
            'items'     => $s->items->where('is_active', true)->values()->map(fn ($i) => [
                'id'         => $i->id,
                'name_en'    => $i->name_en,
                'name_ar'    => $i->name_ar,
                'normal_min' => $i->normal_min,
                'normal_max' => $i->normal_max,
            ])->all(),
        ])->values()->all();
    }

    /**
     * Writes the doctor's values into the report sections.
     * @param array $values       item_id => { right?, left?, value?, text? }
     * @param array $sectionNotes section_id => text
     */
    public function applyValues(array $sections, array $values, array $sectionNotes): array
    {
        $errors = [];

        foreach ($sections as &$section) {
            $type = $section['type'];
            if (array_key_exists((string) $section['id'], $sectionNotes) || array_key_exists($section['id'], $sectionNotes)) {
                $note = $sectionNotes[$section['id']] ?? $sectionNotes[(string) $section['id']] ?? null;
                $section['notes'] = is_string($note) && trim($note) !== '' ? mb_substr(trim($note), 0, 2000) : null;
            }

            foreach ($section['items'] as &$item) {
                $v = $values[$item['id']] ?? $values[(string) $item['id']] ?? null;
                if (!is_array($v)) continue;
                $label = $item['name_en'];

                switch ($type) {
                    case 'bilateral_number':
                        foreach (['right', 'left'] as $side) {
                            if (array_key_exists($side, $v)) {
                                $item[$side] = $this->number($v[$side], -360, 999, "{$label} ({$side})", $errors);
                            }
                        }
                        break;
                    case 'bilateral_grade':
                        foreach (['right', 'left'] as $side) {
                            if (array_key_exists($side, $v)) {
                                $item[$side] = $this->number($v[$side], $section['scale_min'] ?? 0,
                                    $section['scale_max'] ?? 5, "{$label} ({$side})", $errors, true);
                            }
                        }
                        break;
                    case 'pos_neg':
                        foreach (['right', 'left'] as $side) {
                            if (array_key_exists($side, $v)) {
                                $val = $v[$side];
                                $item[$side] = in_array($val, ['pos', 'neg'], true) ? $val : null;
                            }
                        }
                        break;
                    case 'single_number':
                        if (array_key_exists('value', $v)) {
                            $item['value'] = $this->number($v['value'], $section['scale_min'] ?? -360,
                                $section['scale_max'] ?? 999, $label, $errors);
                        }
                        break;
                    case 'text':
                        if (array_key_exists('text', $v)) {
                            $t = is_string($v['text']) ? trim($v['text']) : '';
                            $item['text'] = $t !== '' ? mb_substr($t, 0, 5000) : null;
                        }
                        break;
                }

                $item['abnormal'] = $this->abnormal($type, $item);
            }
            unset($item);
        }
        unset($section);

        if ($errors) {
            throw ValidationException::withMessages(['values' => $errors]);
        }

        return $sections;
    }

    private function number(mixed $raw, float $min, float $max, string $label, array &$errors, bool $integer = false): ?float
    {
        if ($raw === null || $raw === '') return null;
        $raw = is_string($raw) ? str_replace(',', '.', trim($raw)) : $raw;
        if (!is_numeric($raw)) {
            $errors[] = "{$label}: قيمة غير صحيحة";
            return null;
        }
        $n = (float) $raw;
        if ($n < $min || $n > $max || ($integer && floor($n) != $n)) {
            $errors[] = "{$label}: القيمة يجب أن تكون بين " . (0 + $min) . ' و ' . (0 + $max);
            return null;
        }
        return round($n, 1);
    }

    private function abnormal(string $type, array $item): array|bool
    {
        $out = fn ($v) => $v !== null && (
            ($item['normal_min'] !== null && $v < $item['normal_min']) ||
            ($item['normal_max'] !== null && $v > $item['normal_max'])
        );

        return match ($type) {
            'bilateral_number', 'bilateral_grade' => [
                'right' => $out($item['right'] ?? null),
                'left'  => $out($item['left'] ?? null),
            ],
            'pos_neg' => [
                'right' => ($item['right'] ?? null) === 'pos',
                'left'  => ($item['left'] ?? null) === 'pos',
            ],
            'single_number' => $out($item['value'] ?? null),
            default => false,
        };
    }

    /** Counts shown in report lists. */
    public function stats(array $sections): array
    {
        $filled = 0; $abnormal = 0;
        foreach ($sections as $s) {
            foreach ($s['items'] as $i) {
                $has = collect(['right', 'left', 'value', 'text'])->contains(fn ($k) => ($i[$k] ?? null) !== null);
                if ($has) $filled++;
                $a = $i['abnormal'] ?? false;
                if ($a === true || (is_array($a) && in_array(true, $a, true))) $abnormal++;
            }
        }
        return ['filled' => $filled, 'abnormal' => $abnormal];
    }

    public function format(PatientReport $r, bool $withData = true): array
    {
        $sections = $r->data['sections'] ?? [];
        return [
            'id'             => $r->id,
            'title'          => $r->title,
            'status'         => $r->status,
            'assessed_at'    => $r->assessed_at?->toDateString(),
            'client_id'      => $r->client_id,
            'client_name'    => $r->client?->name,
            'client_code'    => $r->client?->code_label,
            'clinic_id'      => $r->clinic_id,
            'clinic_name'    => $r->clinic?->name,
            'template_id'    => $r->template_id,
            'appointment_id' => $r->appointment_id,
            'notes'          => $r->notes,
            'updated_at'     => $r->updated_at?->toIso8601String(),
        ] + $this->stats($sections) + ($withData ? ['sections' => $sections] : []);
    }
}
