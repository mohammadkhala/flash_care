@extends('layouts.admin')
@section('title', $user->patient?->full_name ?? 'مريض')

@section('content')
@php $patient = $user->patient; @endphp

<div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

    {{-- Sidebar --}}
    <div class="space-y-5">

        {{-- Card --}}
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 text-center">
            <div class="w-20 h-20 rounded-2xl flex items-center justify-center font-black text-3xl text-white mx-auto mb-4"
                 style="background: linear-gradient(135deg,#1B2E6E,#2D4A9E)">
                {{ $patient ? mb_substr($patient->full_name, 0, 1) : '?' }}
            </div>
            <h2 class="font-bold text-xl">{{ $patient?->full_name ?? 'غير مكتمل' }}</h2>
            <p class="text-gray-400 text-sm mt-1">
                {{ $user->phone_country_code }} {{ $user->phone }}
            </p>
            @unless($patient)
                <span class="inline-block mt-2 text-xs bg-amber-50 text-amber-600 px-3 py-1 rounded-full font-semibold">
                    ملف غير مكتمل
                </span>
            @endunless
        </div>

        {{-- Info --}}
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
            <h3 class="font-bold text-sm mb-4" style="color:#1B2E6E">المعلومات</h3>
            <div class="space-y-3 text-sm">
                <div class="flex justify-between">
                    <span class="text-gray-500">الجنس</span>
                    <span class="font-semibold">
                        @if($patient?->gender === 'male') ذكر
                        @elseif($patient?->gender === 'female') أنثى
                        @else <span class="text-gray-300">—</span>
                        @endif
                    </span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-500">المدينة</span>
                    <span class="font-semibold">{{ $patient?->city ?? '—' }}</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-500">تاريخ التسجيل</span>
                    <span class="font-semibold">{{ $user->created_at->format('Y/m/d') }}</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-500">مجموع المواعيد</span>
                    <span class="font-semibold">{{ $patient?->appointments->count() ?? 0 }}</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-500">الحالة</span>
                    <span class="font-semibold {{ $user->is_active ? 'text-green-600' : 'text-red-600' }}">
                        {{ $user->is_active ? 'نشط' : 'موقوف' }}
                    </span>
                </div>
            </div>
        </div>

        {{-- Toggle active --}}
        <form method="POST" action="{{ route('admin.patients.active', $user) }}">
            @csrf
            <button class="w-full py-2.5 rounded-xl text-sm font-semibold transition-colors
                {{ $user->is_active
                    ? 'bg-red-50 text-red-600 hover:bg-red-100'
                    : 'bg-green-50 text-green-600 hover:bg-green-100' }}">
                {{ $user->is_active ? '🔴 إيقاف الحساب' : '🟢 تفعيل الحساب' }}
            </button>
        </form>

        {{-- Delete account --}}
        <form method="POST" action="{{ route('admin.patients.destroy', $user) }}"
              onsubmit="return confirm('⚠️ هل أنت متأكد من حذف هذا الحساب نهائياً؟\nلا يمكن التراجع عن هذا الإجراء.')">
            @csrf
            @method('DELETE')
            <button type="submit"
                class="w-full py-2.5 rounded-xl text-sm font-semibold transition-colors bg-red-600 text-white hover:bg-red-700 mt-1">
                🗑️ حذف الحساب نهائياً
            </button>
        </form>

    </div>

    {{-- Appointments --}}
    <div class="lg:col-span-2">
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm">
            <div class="p-5 border-b border-gray-100">
                <h3 class="font-bold text-sm" style="color:#1B2E6E">سجل المواعيد</h3>
            </div>
            <div class="divide-y divide-gray-50">
                @forelse($patient?->appointments ?? [] as $appt)
                    <div class="px-5 py-4 flex items-center justify-between">
                        <div>
                            <div class="font-semibold text-sm">
                                {{ $appt->therapist->full_name ?? '—' }}
                            </div>
                            <div class="text-xs text-gray-400">
                                {{ $appt->scheduled_at?->format('Y/m/d H:i') ?? '—' }}
                            </div>
                        </div>
                        <span @class([
                            'text-xs font-semibold px-3 py-1 rounded-full',
                            'bg-green-50 text-green-700'  => $appt->status === 'completed',
                            'bg-blue-50 text-blue-700'    => $appt->status === 'confirmed',
                            'bg-yellow-50 text-yellow-700'=> $appt->status === 'pending',
                            'bg-red-50 text-red-700'      => str_contains($appt->status, 'cancelled'),
                        ])>
                            {{ match($appt->status) {
                                'completed' => 'مكتمل',
                                'confirmed' => 'مؤكد',
                                'pending'   => 'معلق',
                                default     => 'ملغي'
                            } }}
                        </span>
                    </div>
                @empty
                    <div class="text-center py-12 text-gray-400 text-sm">
                        <div class="text-3xl mb-2">📅</div>
                        لا توجد مواعيد بعد
                    </div>
                @endforelse
            </div>
        </div>
    </div>

</div>
@endsection
