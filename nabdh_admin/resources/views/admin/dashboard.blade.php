@extends('layouts.admin')
@section('title', 'لوحة التحكم')

@section('content')

{{-- Stats Grid --}}
<div class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
    @php
        $cards = [
            ['label' => 'إجمالي الأخصائيين', 'value' => $stats['total_therapists'],       'icon' => '👨‍⚕️', 'color' => 'blue',   'sub' => $stats['approved_therapists'].' موثق'],
            ['label' => 'إجمالي المرضى',      'value' => $stats['total_patients'],         'icon' => '🧑‍🤝‍🧑', 'color' => 'green',  'sub' => $stats['new_users_today'].' اليوم'],
            ['label' => 'إجمالي المواعيد',    'value' => $stats['total_appointments'],     'icon' => '📅',  'color' => 'purple', 'sub' => $stats['this_month'].' هذا الشهر'],
            ['label' => 'بانتظار الموافقة',   'value' => $stats['pending_therapists'],     'icon' => '⏳',  'color' => 'orange', 'sub' => 'أخصائي جديد'],
        ];
        $colors = [
            'blue'   => 'bg-blue-50 text-blue-600 border-blue-100',
            'green'  => 'bg-green-50 text-green-600 border-green-100',
            'purple' => 'bg-purple-50 text-purple-600 border-purple-100',
            'orange' => 'bg-orange-50 text-orange-600 border-orange-100',
        ];
    @endphp

    @foreach($cards as $card)
        <div class="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm hover:shadow-md transition-shadow">
            <div class="flex items-start justify-between mb-3">
                <div class="w-11 h-11 rounded-xl flex items-center justify-center text-xl {{ $colors[$card['color']] }} border">
                    {{ $card['icon'] }}
                </div>
                <span class="text-xs text-gray-400 bg-gray-50 px-2 py-1 rounded-full">{{ $card['sub'] }}</span>
            </div>
            <div class="text-3xl font-black text-gray-800 mb-1">{{ number_format($card['value']) }}</div>
            <div class="text-sm text-gray-500">{{ $card['label'] }}</div>
        </div>
    @endforeach
</div>

{{-- Chart + Pending --}}
<div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">

    {{-- Monthly Chart --}}
    <div class="lg:col-span-2 bg-white rounded-2xl p-6 border border-gray-100 shadow-sm">
        <h2 class="text-base font-bold text-gray-800 mb-4">المواعيد الشهرية {{ now()->year }}</h2>
        <canvas id="appointmentsChart" height="120"></canvas>
    </div>

    {{-- Quick Stats --}}
    <div class="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm">
        <h2 class="text-base font-bold text-gray-800 mb-4">نظرة سريعة</h2>
        <div class="space-y-4">
            <div class="flex items-center justify-between p-3 bg-green-50 rounded-xl">
                <span class="text-sm text-gray-600">مواعيد مكتملة</span>
                <span class="font-bold text-green-600">{{ $stats['completed_appointments'] }}</span>
            </div>
            <div class="flex items-center justify-between p-3 bg-yellow-50 rounded-xl">
                <span class="text-sm text-gray-600">ريلز بانتظار المراجعة</span>
                <span class="font-bold text-yellow-600">{{ $stats['pending_reels'] }}</span>
            </div>
            <div class="flex items-center justify-between p-3 bg-blue-50 rounded-xl">
                <span class="text-sm text-gray-600">نسبة القبول</span>
                <span class="font-bold text-blue-600">
                    {{ $stats['total_therapists'] > 0 ? round(($stats['approved_therapists'] / $stats['total_therapists']) * 100) : 0 }}%
                </span>
            </div>
        </div>

        <div class="mt-6 space-y-2">
            <a href="{{ route('admin.therapists.index', ['status' => 'pending']) }}"
               class="block w-full text-center bg-[#1B5E7B] text-white text-sm font-semibold py-3 rounded-xl hover:bg-[#154d66] transition-colors">
                مراجعة الطلبات المعلقة ({{ $stats['pending_therapists'] }})
            </a>
            @if($stats['pending_reels'] > 0)
                <a href="{{ route('admin.reels.index', ['status' => 'pending']) }}"
                   class="block w-full text-center bg-amber-500 text-white text-sm font-semibold py-3 rounded-xl hover:bg-amber-600 transition-colors">
                    مراجعة الريلز ({{ $stats['pending_reels'] }})
                </a>
            @endif
        </div>
    </div>
</div>

{{-- Recent Pending Therapists --}}
@if($recentTherapists->isNotEmpty())
<div class="bg-white rounded-2xl border border-gray-100 shadow-sm">
    <div class="flex items-center justify-between p-5 border-b border-gray-100">
        <h2 class="text-base font-bold text-gray-800">أخصائيون بانتظار الموافقة</h2>
        <a href="{{ route('admin.therapists.index', ['status' => 'pending']) }}"
           class="text-sm text-[#1B5E7B] font-semibold hover:underline">عرض الكل</a>
    </div>
    <div class="divide-y divide-gray-50">
        @foreach($recentTherapists as $t)
            <div class="flex items-center justify-between px-5 py-4 hover:bg-gray-50 transition-colors">
                <div class="flex items-center gap-3">
                    <div class="w-10 h-10 rounded-xl bg-[#1B5E7B]/10 flex items-center justify-center text-[#1B5E7B] font-bold text-sm">
                        {{ mb_substr($t->full_name, 0, 1) }}
                    </div>
                    <div>
                        <div class="font-semibold text-sm text-gray-800">{{ $t->full_name }}</div>
                        <div class="text-xs text-gray-400">{{ $t->user->phone_country_code }} {{ $t->user->phone }}</div>
                    </div>
                </div>
                <div class="flex items-center gap-2">
                    <span class="text-xs text-gray-400">{{ $t->created_at->diffForHumans() }}</span>
                    <a href="{{ route('admin.therapists.show', $t) }}"
                       class="text-xs bg-[#1B5E7B] text-white px-3 py-1.5 rounded-lg hover:bg-[#154d66] transition-colors">
                        مراجعة
                    </a>
                </div>
            </div>
        @endforeach
    </div>
</div>
@endif

@endsection

@push('scripts')
<script>
const ctx = document.getElementById('appointmentsChart').getContext('2d');
const chartData = @json($chart);
new Chart(ctx, {
    type: 'bar',
    data: {
        labels: chartData.map(d => d.month),
        datasets: [{
            label: 'المواعيد',
            data: chartData.map(d => d.total),
            backgroundColor: 'rgba(27,94,123,0.15)',
            borderColor: '#1B5E7B',
            borderWidth: 2,
            borderRadius: 8,
            borderSkipped: false,
        }]
    },
    options: {
        responsive: true,
        plugins: { legend: { display: false } },
        scales: {
            y: { beginAtZero: true, grid: { color: '#f0f0f0' }, ticks: { font: { family: 'Cairo' } } },
            x: { grid: { display: false }, ticks: { font: { family: 'Cairo' } } }
        }
    }
});
</script>
@endpush
