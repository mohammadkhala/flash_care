<?php

namespace App\Services;

use App\Models\PatientReport;
use Mpdf\Mpdf;

class ReportPdfService
{
    public function render(PatientReport $report): string
    {
        $report->loadMissing(['therapist.specializations', 'client.patient', 'clinic']);
        $patient = $report->client?->patient;

        $logo = $report->clinic?->logo_path
            ? storage_path('app/public/' . $report->clinic->logo_path)
            : null;

        $html = view('reports.pdf', [
            'report'    => $report,
            'therapist' => $report->therapist,
            'client'    => $report->client,
            'clinic'    => $report->clinic,
            'sections'  => $report->data['sections'] ?? [],
            'logoPath'  => $logo && is_file($logo) ? $logo : null,
            'age'       => $patient?->date_of_birth ? $patient->date_of_birth->age . ' years' : null,
            'dob'       => $patient?->date_of_birth?->format('d/m/Y'),
            'gender'    => match ($patient?->gender) { 'male' => 'Male', 'female' => 'Female', default => null },
        ])->render();

        $tmp = storage_path('app/mpdf');
        if (!is_dir($tmp)) mkdir($tmp, 0775, true);

        $mpdf = new Mpdf([
            'mode'             => 'utf-8',
            'format'           => 'A4',
            'margin_top'       => 12,
            'margin_bottom'    => 18,
            'margin_left'      => 12,
            'margin_right'     => 12,
            'margin_footer'    => 6,
            'default_font'     => 'dejavusans',
            'tempDir'          => $tmp,
            'autoScriptToLang' => true,
            'autoLangToFont'   => true,
        ]);
        $mpdf->SetTitle(trim(($report->number_label ?? '') . ' ' . $report->title . ' — ' . ($report->client?->name ?? '')));
        $mpdf->SetHTMLFooter($this->footer($report));
        $mpdf->WriteHTML($html);

        return $mpdf->Output('', 'S');
    }

    /** Every page: confidentiality, patient identifier, report number, issue/amend dates. */
    private function footer(PatientReport $report): string
    {
        $issued  = ($report->finalized_at ?? $report->created_at ?? now())->format('d/m/Y');
        $amended = $report->finalized_at && $report->updated_at?->gt($report->finalized_at->copy()->addMinutes(5))
            ? ' · Amended ' . $report->updated_at->format('d/m/Y')
            : '';
        $middle = e(collect([
            $report->client?->code_label,
            $report->client?->name,
            $report->number_label,
            'Issued ' . $issued . $amended,
        ])->filter()->join(' · '));

        return '<table width="100%" style="border-top: 0.6px solid #9ca3af; font-size: 7pt; color: #4b5563; font-family: dejavusans;"><tr>'
            . '<td width="30%" style="padding-top: 3px;">CONFIDENTIAL — for medical use only</td>'
            . '<td width="50%" style="padding-top: 3px; text-align: center;">' . $middle . '</td>'
            . '<td width="20%" style="padding-top: 3px; text-align: right;">NABD CARE · Page {PAGENO} of {nbpg}</td>'
            . '</tr></table>';
    }
}
