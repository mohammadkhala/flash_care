@extends('layouts.admin')
@section('title', 'المواعيد')

@section('content')

{{-- Summary Cards --}}
<div class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-5">
    @foreach([
        ['label' => 'إجمالي المواعيد', 'value' => $summary['total'],     'color' => 'bg-blue-50 text-blue-700 border-blue-100'],
        ['label' => 'معلق',             'value' => $summary['pending'],   'color' => 'bg-yellow-50 text-yellow-700 border-yellow-100'],
        ['label' => 'مؤكد',             'value' => $summary['confirmed'], 'color' => 'bg-green-50 text-green-700 border-green-100'],
        ['label' => 'مكتمل',            'value' => $summary['completed'], 'color' => 'bg-purple-50 text-purple-700 border-purple-100'],
    ] as $card)
        <div class="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm">
            <div class="text-3xl font-black mb-1">{{ number_format($card['value']) }}</div>
            <div class="inline-flex text-xs font-semibold px-3 py-1 rounded-full border {{ $card['color'] }}">{{ $card['label'] }}</div>
        </div>
    @endforeach
</div>

<div class="bg-white rounded-2xl border border-gray-100 shadow-sm">
    {{-- Filters --}}
    <div class="p-4 border-b border-gray-100">
        <form method="GET" action="{{ route('admin.appointments.index') }}" class="flex flex-wrap gap-3">
            <input type="text" name="search" value="{{ request('search') }}" placeholder="بحث..."
                   class="flex-1 min-w-48 border border-gray-200 rounded-xl px-4 py-2 text-sm focus:outline-none focus:border-[#1B5E7B]">
            <select name="status" class="border border-gray-200 rounded-xl px-4 py-2 text-sm focus:outline-none focus:border-[#1B5E7B]">
                <option value="">كل الحالات</option>
                @foreach(['pending' => 'معلق', 'confirmed' => 'مؤكد', 'completed' => 'مكتمل', 'cancelled_by_patient' => 'ملغي من المريض', 'cancelled_by_therapist' => 'ملغي من الأخصائي'] as $val => $label)
                    <option value="{{ $val }}" {{ request('status') === $val ? 'selected' : '' }}>{{ $label }}</option>
                @endforeach
            </select>
            <select name="type" class="border border-gray-200 rounded-xl px-4 py-2 text-sm focus:outline-none focus:border-[#1B5E7B]">
                <option value="">كل الأنواع</option>
                <option value="in_person" {{ request('type') === 'in_person' ? 'selected' : '' }}>حضوري</option>
                <option value="online" {{ request('type') === 'online' ? 'selected' : '' }}>عن بُعد</option>
            </select>
            <input type="date" name="date" value="{{ request('date') }}"
                   class="border border-gray-200 rounded-xl px-4 py-2 text-sm focus:outline-none focus:border-[#1B5E7B]">
            <button class="bg-[#1B5E7B] text-white px-5 py-2 rounded-xl text-sm font-semibold hover:bg-[#154d66] transition-colors">
                فلترة
            </button>
        </form>
    </div>

    {{-- Table --}}
    <div class="overflow-x-auto">
        <table class="w-full text-sm">
            <thead>
                <tr class="bg-gray-50 text-gray-500 text-xs font-semibold">
                    <th class="px-5 py-3 text-right">#</th>
                    <th class="px-5 py-3 text-right">الأخصائي</th>
                    <th class="px-5 py-3 text-right">المريض</th>
                    <th class="px-5 py-3 text-right">الموعد</th>
                    <th class="px-5 py-3 text-right">النوع</th>
                    <th class="px-5 py-3 text-right">الحالة</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-50">
                @forelse($appointments as $appt)
                    <tr class="hover:bg-gray-50/50 transition-colors">
                        <td class="px-5 py-3 text-gray-400 font-mono text-xs">#{{ $appt->id }}</td>
                        <td class="px-5 py-3 font-semibold text-gray-800">{{ $appt->therapist->full_name ?? '-' }}</td>
                        <td class="px-5 py-3 text-gray-600">{{ $appt->patient->full_name ?? '-' }}</td>
                        <td class="px-5 py-3 text-gray-500 text-xs">{{ $appt->scheduled_at->format('Y/m/d H:i') }}</td>
                        <td class="px-5 py-3">
                            <span class="text-xs px-2 py-1 rounded-full {{ $appt->type === 'online' ? 'bg-blue-50 text-blue-600' : 'bg-gray-50 text-gray-600' }}">
                                {{ $appt->type === 'online' ? '💻 عن بُعد' : '🏥 حضوري' }}
                            </span>
                        </td>
                        <td class="px-5 py-3">
                            <span @class([
                                'text-xs font-semibold px-3 py-1 rounded-full',
                                'bg-green-50 text-green-700' => $appt->status === 'completed',
                                'bg-blue-50 text-blue-700' => $appt->status === 'confirmed',
                                'bg-yellow-50 text-yellow-700' => $appt->status === 'pending',
                                'bg-red-50 text-red-700' => str_contains($appt->status, 'cancelled'),
                            ])>
                                {{ match($appt->status) {
                                    'completed' => 'مكتمل',
                                    'confirmed' => 'مؤكد',
                                    'pending' => 'معلق',
                                    'cancelled_by_patient' => 'ملغي - مريض',
                                    'cancelled_by_therapist' => 'ملغي - أخصائي',
                                    default => $appt->status,
                                } }}
                            </span>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="6" class="text-center py-16 text-gray-400">
                            <div class="text-4xl mb-3">📅</div>
                            <div>لا توجد مواعيد</div>
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
    @if($appointments->hasPages())
        <div class="px-5 py-4 border-t border-gray-100">{{ $appointments->links() }}</div>
    @endif
</div>
@endsection
