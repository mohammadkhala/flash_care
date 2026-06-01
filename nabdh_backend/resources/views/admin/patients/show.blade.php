@extends('layouts.admin')
@section('title', $user->patient?->full_name ?? 'مريض')

@section('content')

@if(session('success'))
    <div class="mb-5 bg-green-50 border border-green-200 text-green-800 text-sm font-semibold px-4 py-3 rounded-xl">
        {{ session('success') }}
    </div>
@endif

@php $patient = $user->patient; @endphp

<div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

    {{-- ─── Sidebar ──────────────────────────────────────────────────────── --}}
    <div class="space-y-5">

        {{-- Card --}}
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 text-center">
            @if($patient?->avatar)
                <img src="{{ Storage::url($patient->avatar) }}"
                     class="w-20 h-20 rounded-2xl mx-auto mb-4 object-cover">
            @else
                <div class="w-20 h-20 rounded-2xl flex items-center justify-center font-black text-3xl text-white mx-auto mb-4"
                     style="background:linear-gradient(135deg,#1B2E6E,#2D4A9E)">
                    {{ $patient ? mb_substr($patient->full_name, 0, 1) : '?' }}
                </div>
            @endif
            <h2 class="font-bold text-xl">{{ $patient?->full_name ?? 'غير مكتمل' }}</h2>
            <p class="text-gray-400 text-sm mt-1">{{ $user->phone_country_code }} {{ $user->phone }}</p>
            <div class="mt-3 flex flex-wrap justify-center gap-2">
                @unless($patient)
                    <span class="text-xs bg-amber-50 text-amber-600 px-3 py-1 rounded-full font-semibold border border-amber-100">ملف غير مكتمل</span>
                @endunless
                <span class="{{ $user->is_active ? 'bg-green-50 text-green-700 border-green-100' : 'bg-red-50 text-red-700 border-red-100' }} text-xs font-semibold px-3 py-1 rounded-full border">
                    {{ $user->is_active ? '🟢 نشط' : '🔴 موقوف' }}
                </span>
            </div>
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
                    <span class="text-gray-500">تاريخ الميلاد</span>
                    <span class="font-semibold">{{ $patient?->date_of_birth?->format('Y/m/d') ?? '—' }}</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-500">المدينة</span>
                    <span class="font-semibold">{{ $patient?->city ?? '—' }}</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-500">إجمالي المواعيد</span>
                    <span class="font-semibold">{{ $patient?->appointments->count() ?? 0 }}</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-500">البرامج المنزلية</span>
                    <span class="font-semibold">{{ $patient?->homePrograms->count() ?? 0 }}</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-500">تاريخ التسجيل</span>
                    <span class="font-semibold">{{ $user->created_at->format('Y/m/d') }}</span>
                </div>
            </div>
        </div>

        @if($patient?->medical_history || $patient?->allergies)
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
                <h3 class="font-bold text-sm text-gray-700 mb-3">المعلومات الطبية</h3>
                @if($patient->medical_history)
                    <div class="mb-3">
                        <p class="text-xs text-gray-500 font-semibold mb-1">التاريخ الطبي</p>
                        <p class="text-sm text-gray-600 leading-relaxed">{{ $patient->medical_history }}</p>
                    </div>
                @endif
                @if($patient->allergies)
                    <div>
                        <p class="text-xs text-gray-500 font-semibold mb-1">الحساسية</p>
                        <p class="text-sm text-gray-600">{{ $patient->allergies }}</p>
                    </div>
                @endif
            </div>
        @endif

        @if($patient?->emergency_contact_name)
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
                <h3 class="font-bold text-sm text-gray-700 mb-3">جهة الطوارئ</h3>
                <p class="text-sm font-semibold text-gray-700">{{ $patient->emergency_contact_name }}</p>
                <p class="text-sm text-gray-500">{{ $patient->emergency_contact_phone }}</p>
            </div>
        @endif

        {{-- Actions --}}
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
            <h3 class="font-bold text-sm text-gray-700 mb-3">الإجراءات</h3>
            <div class="space-y-2">
                <a href="{{ route('admin.patients.edit', $user) }}"
                   class="block text-center font-semibold py-2.5 rounded-xl text-sm transition-colors text-white"
                   style="background:#1B2E6E">
                    ✏️ تعديل البيانات
                </a>
                <form method="POST" action="{{ route('admin.patients.active', $user) }}">
                    @csrf
                    <button class="w-full py-2.5 rounded-xl text-sm font-semibold transition-colors
                        {{ $user->is_active ? 'bg-orange-50 text-orange-600 hover:bg-orange-100' : 'bg-green-50 text-green-600 hover:bg-green-100' }}">
                        {{ $user->is_active ? '🔴 إيقاف الحساب' : '🟢 تفعيل الحساب' }}
                    </button>
                </form>
                <form method="POST" action="{{ route('admin.patients.destroy', $user) }}"
                      onsubmit="return confirm('⚠️ هل أنت متأكد من حذف هذا الحساب نهائياً؟')">
                    @csrf @method('DELETE')
                    <button type="submit"
                        class="w-full py-2.5 rounded-xl text-sm font-semibold transition-colors bg-red-600 text-white hover:bg-red-700">
                        🗑️ حذف نهائي
                    </button>
                </form>
            </div>
        </div>
    </div>

    {{-- ─── Main Content ──────────────────────────────────────────────────── --}}
    <div class="lg:col-span-2 space-y-5">

        {{-- Send Notification --}}
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5" x-data="{ open: false }">
            <div class="flex items-center justify-between cursor-pointer" @click="open = !open">
                <h3 class="font-bold text-sm text-gray-700">📣 إرسال إشعار للمريض</h3>
                <span class="text-gray-400 text-sm" x-text="open ? '▲' : '▼'"></span>
            </div>
            <div x-show="open" x-transition class="mt-4">
                <form method="POST" action="{{ route('admin.patients.notify', $user) }}" class="space-y-3">
                    @csrf
                    <input type="text" name="title" required placeholder="عنوان الإشعار"
                           class="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm focus:outline-none"
                           style="focus:border-color:#1B2E6E">
                    <textarea name="body" rows="3" required placeholder="نص الإشعار..."
                              class="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm focus:outline-none resize-none"></textarea>
                    <button class="text-white font-bold px-5 py-2 rounded-xl text-sm transition-colors"
                            style="background:#1B2E6E">
                        📤 إرسال الإشعار
                    </button>
                </form>
            </div>
        </div>

        {{-- Appointments --}}
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm">
            <div class="p-5 border-b border-gray-100 flex items-center justify-between">
                <h3 class="font-bold text-sm" style="color:#1B2E6E">سجل المواعيد</h3>
                <span class="text-xs text-gray-400">{{ $patient?->appointments->count() ?? 0 }} موعد</span>
            </div>
            <div class="divide-y divide-gray-50">
                @forelse($patient?->appointments ?? [] as $appt)
                    <a href="{{ route('admin.appointments.show', $appt) }}"
                       class="px-5 py-4 flex items-center justify-between hover:bg-gray-50 transition-colors block">
                        <div>
                            <div class="font-semibold text-sm">{{ $appt->therapist->full_name ?? '—' }}</div>
                            <div class="text-xs text-gray-400">{{ $appt->scheduled_at?->format('Y/m/d H:i') ?? '—' }}</div>
                        </div>
                        <span @class([
                            'text-xs font-semibold px-3 py-1 rounded-full',
                            'bg-green-50 text-green-700'   => $appt->status === 'completed',
                            'bg-blue-50 text-blue-700'     => $appt->status === 'confirmed',
                            'bg-yellow-50 text-yellow-700' => $appt->status === 'pending',
                            'bg-red-50 text-red-700'       => str_contains($appt->status, 'cancelled'),
                        ])>
                            {{ match($appt->status) {
                                'completed' => 'مكتمل','confirmed' => 'مؤكد',
                                'pending' => 'معلق', default => 'ملغي'
                            } }}
                        </span>
                    </a>
                @empty
                    <div class="text-center py-12 text-gray-400 text-sm">
                        <div class="text-3xl mb-2">📅</div>لا توجد مواعيد بعد
                    </div>
                @endforelse
            </div>
        </div>

        {{-- Home Programs --}}
        @if($patient?->homePrograms->isNotEmpty())
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm">
                <div class="p-5 border-b border-gray-100">
                    <h3 class="font-bold text-sm text-gray-700">البرامج المنزلية</h3>
                </div>
                <div class="divide-y divide-gray-50">
                    @foreach($patient->homePrograms as $prog)
                        <div class="px-5 py-3 flex items-center justify-between">
                            <div>
                                <div class="text-sm font-semibold">{{ $prog->title }}</div>
                                <div class="text-xs text-gray-400">{{ $prog->description }}</div>
                            </div>
                            <span class="text-xs text-gray-400">{{ $prog->created_at->format('Y/m/d') }}</span>
                        </div>
                    @endforeach
                </div>
            </div>
        @endif

    </div>
</div>
@endsection
