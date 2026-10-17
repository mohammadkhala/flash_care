<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
    body { font-family: dejavusans; font-size: 9.5pt; color: #1f2937; }
    .head { width: 100%; border-bottom: 2.5px solid #0D47A1; padding-bottom: 6px; }
    .head td { vertical-align: middle; }
    .clinic-name { font-size: 15pt; font-weight: bold; color: #0D47A1; }
    .muted { color: #6b7280; font-size: 8.5pt; }
    .title { text-align: center; font-size: 14pt; font-weight: bold; color: #0F1D48; margin: 12px 0 8px; }
    .info { width: 100%; border: 1px solid #dbe3f0; background: #f5f8fd; border-radius: 6px; margin-bottom: 10px; }
    .info td { padding: 5px 8px; font-size: 9pt; }
    .info b { color: #0F1D48; }
    .section { margin-top: 10px; }
    .sec-head { background: #1565C0; color: #fff; font-weight: bold; padding: 5px 8px; font-size: 10pt; }
    table.grid { width: 100%; border-collapse: collapse; }
    table.grid th { background: #E3ECF8; color: #0F1D48; font-size: 8.5pt; padding: 4px 6px; border: 1px solid #c9d6ea; }
    table.grid td { padding: 4px 6px; border: 1px solid #dbe3f0; font-size: 9pt; }
    table.grid td.c { text-align: center; }
    .ab { color: #C62828; font-weight: bold; }
    .ar { color: #6b7280; font-size: 8pt; }
    .text-item { margin: 4px 0 6px; }
    .text-item .lbl { font-weight: bold; color: #0F1D48; }
    .notes { border: 1px solid #dbe3f0; border-top: none; padding: 5px 8px; font-size: 8.5pt; color: #374151; }
    .legend { font-size: 7.5pt; color: #6b7280; margin-top: 3px; }
    .sign { margin-top: 28px; width: 100%; }
    .sign td { font-size: 9pt; }
</style>
</head>
<body>

<table class="head">
    <tr>
        <td style="width: 60%;">
            <div class="clinic-name">{{ $clinic?->name ?? $therapist->full_name }}</div>
            @if($clinic)
                <div class="muted">{{ collect([$clinic->address, $clinic->city])->filter()->join('، ') }}</div>
                @if($clinic->phone)<div class="muted">Tel: {{ $clinic->phone }}</div>@endif
            @endif
            <div style="margin-top: 4px; font-size: 9.5pt;"><b>{{ $therapist->full_name }}</b>
                @if($therapist->title || $therapist->degree)
                    <span class="muted"> — {{ collect([$therapist->title, $therapist->degree])->filter()->join(' · ') }}</span>
                @endif
            </div>
            @if($specializations)<div class="muted">{{ $specializations }}</div>@endif
        </td>
        <td style="width: 40%; text-align: right;">
            @if($logoPath)
                <img src="{{ $logoPath }}" style="max-height: 70px; max-width: 170px;">
            @endif
        </td>
    </tr>
</table>

<div class="title">{{ $report->title }}</div>

<table class="info">
    <tr>
        <td><b>Patient:</b> {{ $client->name }}</td>
        <td><b>ID:</b> {{ $client->code_label }}</td>
        <td><b>Date:</b> {{ $report->assessed_at->format('d/m/Y') }}</td>
    </tr>
    <tr>
        <td><b>Age:</b> {{ $age ?? '—' }}</td>
        <td><b>Gender:</b> {{ $gender ?? '—' }}</td>
        <td><b>Institution:</b> {{ $clinic?->name ?? '—' }}</td>
    </tr>
</table>

@php $n = 0; @endphp
@foreach($sections as $section)
    @php
        $type  = $section['type'];
        $unit  = $section['unit'] ?? '';
        $items = collect($section['items'])->filter(fn ($i) =>
            collect(['right', 'left', 'value', 'text'])->contains(fn ($k) => ($i[$k] ?? null) !== null))->values();
        $fmt = fn ($v) => $v === null ? '—' : rtrim(rtrim(number_format((float) $v, 1, '.', ''), '0'), '.');
        $range = function ($i) use ($fmt, $unit, $type) {
            if ($i['normal_min'] === null && $i['normal_max'] === null) return '—';
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
    @endphp
    @continue($items->isEmpty() && empty($section['notes']))
    @php $n++; @endphp

    <div class="section">
        <div class="sec-head">{{ $n }}. {{ $section['name_en'] }}</div>

        @if($type === 'text')
            <div style="border: 1px solid #dbe3f0; border-top: none; padding: 4px 8px;">
                @foreach($items as $i)
                    <div class="text-item"><span class="lbl">{{ $i['name_en'] }}:</span> {!! nl2br(e($i['text'])) !!}</div>
                @endforeach
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
                        <th>{{ $type === 'bilateral_grade' ? 'Normal (' . rtrim(rtrim(number_format((float) ($section['scale_min'] ?? 0), 1, '.', ''), '0'), '.') . '–' . rtrim(rtrim(number_format((float) ($section['scale_max'] ?? 5), 1, '.', ''), '0'), '.') . ')' : 'Normal Range' }}</th>
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

@if($report->notes)
    <div class="section">
        <div class="sec-head">Additional Notes</div>
        <div class="notes">{!! nl2br(e($report->notes)) !!}</div>
    </div>
@endif

<div class="legend">Values in <span class="ab">red</span> are outside the normal range / positive tests.</div>

<table class="sign">
    <tr>
        <td style="width: 50%;">Therapist: <b>{{ $therapist->full_name }}</b></td>
        <td style="width: 50%; text-align: right;">Signature: ______________________</td>
    </tr>
</table>

</body>
</html>
