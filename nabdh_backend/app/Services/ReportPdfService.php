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
            'report'          => $report,
            'therapist'       => $report->therapist,
            'client'          => $report->client,
            'clinic'          => $report->clinic,
            'sections'        => $report->data['sections'] ?? [],
            'logoPath'        => $logo && is_file($logo) ? $logo : null,
            'specializations' => $report->therapist->specializations->pluck('name_en')->filter()->join(' · '),
            'age'             => $patient?->date_of_birth ? $patient->date_of_birth->age . ' years' : null,
            'gender'          => match ($patient?->gender) { 'male' => 'Male', 'female' => 'Female', default => null },
        ])->render();

        $tmp = storage_path('app/mpdf');
        if (!is_dir($tmp)) mkdir($tmp, 0775, true);

        $mpdf = new Mpdf([
            'mode'             => 'utf-8',
            'format'           => 'A4',
            'margin_top'       => 12,
            'margin_bottom'    => 16,
            'margin_left'      => 12,
            'margin_right'     => 12,
            'default_font'     => 'dejavusans',
            'tempDir'          => $tmp,
            'autoScriptToLang' => true,
            'autoLangToFont'   => true,
        ]);
        $mpdf->SetTitle($report->title . ' — ' . ($report->client?->name ?? ''));
        $mpdf->SetFooter('NABD CARE||Page {PAGENO} of {nbpg}');
        $mpdf->WriteHTML($html);

        return $mpdf->Output('', 'S');
    }
}
