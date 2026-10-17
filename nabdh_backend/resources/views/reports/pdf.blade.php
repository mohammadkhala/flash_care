<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
    body { font-family: dejavusans; font-size: 9.5pt; color: #1f2937; }
    table.head { width: 100%; border-collapse: collapse; }
    table.head td { vertical-align: top; }
    .cn { font-size: 13pt; font-weight: bold; color: #0D47A1; }
    .tn { font-size: 9.5pt; font-weight: bold; margin-top: 4px; }
    .tt { font-size: 8.5pt; color: #4b5563; }
    .lic { font-size: 8pt; color: #0D47A1; margin-top: 2px; }
    .bar { border-top: 2.5px solid #0D47A1; margin-top: 6px; }
    .contact { text-align: center; font-size: 8pt; color: #4b5563; padding-top: 3px; }
    .title { text-align: center; font-size: 14pt; font-weight: bold; color: #0F1D48; margin: 10px 0 2px; }
    .subtitle { text-align: center; font-size: 9pt; color: #374151; margin-bottom: 8px; }
    .badge { background-color: #1565C0; color: #ffffff; font-weight: bold; font-size: 8.5pt; padding: 2px 8px; }
    .info { width: 100%; border: 1px solid #dbe3f0; background: #f5f8fd; margin-bottom: 8px; border-collapse: collapse; }
    .info td { padding: 4px 7px; font-size: 8.8pt; vertical-align: top; }
    .info b { color: #0F1D48; }
    .section { margin-top: 9px; }
    .sec-head { background: #1565C0; color: #fff; font-weight: bold; padding: 5px 8px; font-size: 10pt; }
    table.grid { width: 100%; border-collapse: collapse; }
    table.grid th { background: #E3ECF8; color: #0F1D48; font-size: 8.5pt; padding: 4px 6px; border: 1px solid #c9d6ea; }
    table.grid td { padding: 4px 6px; border: 1px solid #dbe3f0; font-size: 9pt; }
    table.grid td.c { text-align: center; }
    .ab { color: #C62828; font-weight: bold; }
    .text-item { margin: 4px 0 6px; }
    .text-item .lbl { font-weight: bold; color: #0F1D48; }
    .notes { border: 1px solid #dbe3f0; border-top: none; padding: 5px 8px; font-size: 8.5pt; color: #374151; }
    .legend { font-size: 7.5pt; color: #6b7280; margin-top: 4px; }
    table.sign { width: 100%; margin-top: 22px; }
    table.sign td { font-size: 9pt; vertical-align: bottom; }
    .stamp { width: 95px; height: 70px; border: 1.5px dashed #9ca3af; color: #9ca3af; text-align: center; font-size: 8pt; }
</style>
</head>
<body>

@php
    $fmtDate = fn ($d) => $d ? $d->format('d/m/Y') : '—';
    $licEn = collect([
        $therapist->license_number ? 'PT License (MoH): ' . $therapist->license_number : null,
        $therapist->syndicate_number ? 'Syndicate No.: ' . $therapist->syndicate_number : null,
    ])->filter()->join(' · ');
    $licAr = collect([
        $therapist->license_number ? 'رقم إجازة المزاولة (وزارة الصحة): ' . $therapist->license_number : null,
        $therapist->syndicate_number ? 'رقم النقابة: ' . $therapist->syndicate_number : null,
    ])->filter()->join(' · ');
    $contact = collect([
        collect([collect([$clinic?->address, $clinic?->city])->filter()->join('، '), $clinic?->address_en])->filter()->join(' — '),
        $clinic?->phone ? 'Tel: ' . $clinic->phone : null,
        $clinic?->email,
        $clinic?->website,
    ])->filter();
    $therapistEn = $therapist->full_name_en ?: $therapist->full_name;
@endphp

{{-- ── Letterhead: English | logo | Arabic ─────────────────────── --}}
<table class="head">
    <tr>
        <td style="width: 40%; text-align: left;">
            @if($clinic?->name_en)<div class="cn">{{ $clinic->name_en }}</div>@endif
            @if($therapist->full_name_en)<div class="tn">{{ $therapist->full_name_en }}</div>@endif
            @php $ttEn = collect([$therapist->title_en, $therapist->degree_en])->filter()->join(' · '); @endphp
            @if($ttEn)<div class="tt">{{ $ttEn }}</div>@endif
            @if($licEn)<div class="lic">{{ $licEn }}</div>@endif
            @if($clinic?->license_number)<div class="lic">Center License No.: {{ $clinic->license_number }}</div>@endif
        </td>
        <td style="width: 20%; text-align: center; vertical-align: middle;">
            @if($logoPath)<img src="{{ $logoPath }}" style="max-height: 72px; max-width: 120px;">@endif
        </td>
        <td style="width: 40%; text-align: right;" dir="rtl">
            @if($clinic)<div class="cn">{{ $clinic->name }}</div>@endif
            <div class="tn">{{ $therapist->full_name }}</div>
            @php $ttAr = collect([$therapist->title, $therapist->degree])->filter()->join(' · '); @endphp
            @if($ttAr)<div class="tt">{{ $ttAr }}</div>@endif
            @if($licAr)<div class="lic">{{ $licAr }}</div>@endif
            @if($clinic?->license_number)<div class="lic">رقم ترخيص المركز: {{ $clinic->license_number }}</div>@endif
        </td>
    </tr>
</table>
<div class="bar"></div>
@if($contact->isNotEmpty())
    <div class="contact">{{ $contact->join('   ·   ') }}</div>
@endif

{{-- ── Title ──────────────────────────────────────────────────── --}}
<div class="title">Physiotherapy Assessment Report</div>
<div class="subtitle">
    <span class="badge">{{ \App\Models\PatientReport::TYPES[$report->report_type] ?? 'Assessment' }}</span>
    &nbsp; {{ $report->title }}
    @if($report->number_label) &nbsp;·&nbsp; <b>Report No.: {{ $report->number_label }}</b>@endif
</div>

<table class="info">
    <tr>
        <td style="width: 38%;"><b>Patient:</b> {{ $client->name }}</td>
        <td style="width: 24%;"><b>ID:</b> {{ $client->code_label }}</td>
        <td style="width: 38%;"><b>Assessment Date:</b> {{ $fmtDate($report->assessed_at) }}</td>
    </tr>
    <tr>
        <td><b>Age / DOB:</b> {{ $age ?? '—' }}{{ $dob ? ' · ' . $dob : '' }}</td>
        <td><b>Gender:</b> {{ $gender ?? '—' }}</td>
        <td><b>Institution:</b> {{ $clinic ? ($clinic->name_en ?: $clinic->name) : '—' }}</td>
    </tr>
    @if($report->referral_source || $report->medical_diagnosis)
        <tr>
            <td colspan="{{ $report->medical_diagnosis ? 1 : 3 }}"><b>Referral:</b>
                {{ \App\Models\PatientReport::REFERRALS[$report->referral_source] ?? '—' }}{{ $report->referral_name ? ' — ' . $report->referral_name : '' }}
            </td>
            @if($report->medical_diagnosis)
                <td colspan="2"><b>Medical Diagnosis:</b> {{ $report->medical_diagnosis }}</td>
            @endif
        </tr>
    @endif
</table>

{{-- ── Sections ───────────────────────────────────────────────── --}}
@php $n = 0; @endphp
@foreach($sections as $section)
    @php
        $type  = $section['type'];
        $unit  = $section['unit'] ?? '';
        $items = collect($section['items'])->filter(fn ($i) =>
            collect(['right', 'left', 'value', 'text'])->contains(fn ($k) => ($i[$k] ?? null) !== null))->values();
        $fmt = fn ($v) => $v === null ? '—' : rtrim(rtrim(number_format((float) $v, 1, '.', ''), '0'), '.');
        $range = function ($i) use ($fmt, $unit, $type) {
            if (($i['normal_min'] ?? null) === null && ($i['normal_max'] ?? null) === null) return '—';
            if ($type === 'bilateral_grade') return $fmt($i['normal_max']) . $unit;
            return $fmt($i['normal_min']) . ' – ' . $fmt($i['normal_max']) . ($unit === '°' ? '°' : '');
        };
        $cell = function ($i, $side) use ($fmt, $unit, $type) {
            $v = $i[$side] ?? null;
            if ($v === null) return '—';
            $ab = is_array($i['abnormal'] ?? null) && ($i['abnormal'][$side] ?? false);
            $txt = $type === 'pos_neg' ? ($v === 'pos' ? 'Positive (+)' : 'Negative (−)') : $fmt($v) . ($unit === '°' ? '°' : '');
            return $ab ? '<span class="ab">' . e($txt) . '</span>' : e($txt);
        };
        $isPlan = $section['name_en'] === 'Assessment & Plan';
    @endphp
    @continue($items->isEmpty() && empty($section['notes']) && !($isPlan && $report->plan_of_care))
    @php $n++; @endphp

    <div class="section">
        <div class="sec-head">{{ $n }}. {{ $section['name_en'] }}</div>

        @if($type === 'text')
            <div style="border: 1px solid #dbe3f0; border-top: none; padding: 4px 8px;">
                @foreach($items as $i)
                    <div class="text-item"><span class="lbl">{{ $i['name_en'] }}:</span> {!! nl2br(e($i['text'])) !!}</div>
                    @if($isPlan && $i['name_en'] === 'Treatment Plan' && $report->plan_of_care)
                        <div class="text-item"><span class="lbl">Plan of Care:</span> {{ $report->plan_of_care }}</div>
                        @php $planShown = true; @endphp
                    @endif
                @endforeach
                @if($isPlan && $report->plan_of_care && empty($planShown))
                    <div class="text-item"><span class="lbl">Plan of Care:</span> {{ $report->plan_of_care }}</div>
                    @php $planShown = true; @endphp
                @endif
            </div>
        @elseif($items->isNotEmpty())
            <table class="grid">
                <thead>
                <tr>
                    <th style="text-align: left;">{{ match (true) {
                        $type === 'pos_neg' => 'Test',
                        str_contains($section['name_en'], 'Muscle') => 'Muscle Group',
                        $unit === '°' => 'Joint / Movement',
                        default => 'Item',
                    } }}</th>
                    @if($type === 'single_number')
                        <th>Value</th>
                    @else
                        <th>Right</th><th>Left</th>
                    @endif
                    @if($type !== 'pos_neg')
                        <th>{{ $type === 'bilateral_grade' ? 'Normal (' . $fmt($section['scale_min'] ?? 0) . '–' . $fmt($section['scale_max'] ?? 5) . ')' : 'Normal Range' }}</th>
                    @endif
                </tr>
                </thead>
                <tbody>
                @foreach($items as $i)
                    <tr>
                        <td>{{ $i['name_en'] }}</td>
                        @if($type === 'single_number')
                            @php $v = $i['value'] ?? null; $ab = ($i['abnormal'] ?? false) === true; @endphp
                            <td class="c">{!! $v === null ? '—' : ($ab ? '<span class="ab">' : '') . e($fmt($v) . ($unit === '/10' ? ' /10' : ($unit === '°' ? '°' : ''))) . ($ab ? '</span>' : '') !!}</td>
                        @else
                            <td class="c">{!! $cell($i, 'right') !!}</td>
                            <td class="c">{!! $cell($i, 'left') !!}</td>
                        @endif
                        @if($type !== 'pos_neg')
                            <td class="c">{{ $range($i) }}</td>
                        @endif
                    </tr>
                @endforeach
                </tbody>
            </table>
        @endif

        @if(!empty($section['notes']))
            <div class="notes"><b>Notes:</b> {!! nl2br(e($section['notes'])) !!}</div>
        @endif
    </div>
@endforeach

@if($report->plan_of_care && empty($planShown))
    <div class="section">
        <div class="sec-head">Plan of Care</div>
        <div class="notes">{{ $report->plan_of_care }}</div>
    </div>
@endif

@if($report->notes)
    <div class="section">
        <div class="sec-head">Additional Notes</div>
        <div class="notes">{!! nl2br(e($report->notes)) !!}</div>
    </div>
@endif

<div class="legend">Values in <span class="ab">red</span> are outside the normal range / positive tests.</div>

{{-- ── Signature & stamp ──────────────────────────────────────── --}}
<table class="sign">
    <tr>
        <td style="width: 70%;">
            Therapist: <b>{{ $therapistEn }}</b>{{ $therapist->title_en ? ', ' . $therapist->title_en : '' }}<br>
            @if($therapist->license_number)<span style="font-size: 8pt; color: #4b5563;">PT License (MoH): {{ $therapist->license_number }}</span><br>@endif
            <br>Signature: ______________________
        </td>
        <td style="width: 30%; text-align: right;">
            <table align="right"><tr><td class="stamp">Clinic Stamp</td></tr></table>
        </td>
    </tr>
</table>

</body>
</html>
