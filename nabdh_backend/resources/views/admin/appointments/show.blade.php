@extends('layouts.admin')
@section('title', 'تفاصيل الموعد #' . $appointment->id)

@section('content')

@if(session('success'))
    <div class="mb-5 bg-green-50 border border-green-200 text-green-800 text-sm font-semibold px-4 py-3 rounded-xl">
        {{ session('success') }}
    </div>
@endif

<div class="mb-5 flex items-center gap-3">
    <a href="{{ route('admin.appointments.index') }}" class="text-gray-400 hover:text-gray-700 text-sm">← رجوع</a>
    <span class="text-gray-300">/</span>
    <h1 class="text-lg font-bold text-gray-800">الموعد #{{ $appointment->id }}</h1>
</div>

<div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

    {{-- Info Card --}}
    <div class="space-y-5">
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
            <h3 class="font-bold text-sm text-gray-700 mb-4">تفاصيل الموعد</h3>
            <div class="space-y-3 text-sm">
                <div class="flex justify-between">
                    <span class="text-gray-500">التاريخ والوقت</span>
                    <span class="font-semibold">{{ $appointment->scheduled_at->format('Y/m/d H:i') }}</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-500">النوع</span>
                    <span class="font-semibold">{{ $appointment->type === 'online' ? '🌐 أونلاين' : '🏥 حضوري' }}</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-500">المدة</span>
                    <span class="font-semibold">{{ $appointment->duration ?? '—' }} دقيقة</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-500">السعر</span>
                    <span class="font-semibold">{{ $appointment->price ? '₪'.$appointment->price : '—' }}</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-500">الحالة</span>
                    <span @class([
                        'font-semibold px-2 py-0.5 rounded-full text-xs',
                        'bg-green-100 text-green-700'  => $appointment->status === 'completed',
                        'bg-blue-100 text-blue-700'    => $appointment->status === 'confirmed',
                        'bg-yellow-100 text-yellow-700'=> $appointment->status === 'pending',
                        'bg-red-100 text-red-700'      => str_contains($appointment->status, 'cancelled'),
                    ])>
                        {{ match($appointment->status) {
                            'completed' => 'مكتمل','confirmed' => 'مؤكد',
                            'pending' => 'معلق', default => 'ملغي',
                        } }}
                    </span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-500">أُنشئ</span>
                    <span class="font-semibold">{{ $appointment->created_at->format('Y/m/d') }}</span>
                </div>
            </div>
        </div>

        {{-- Therapist --}}
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
            <h3 class="font-bold text-sm text-gray-700 mb-3">الأخصائي</h3>
            <a href="{{ route('admin.therapists.show', $appointment->therapist) }}"
               class="flex items-center gap-3 hover:bg-gray-50 p-2 rounded-xl transition-colors -m-2">
                <div class="w-10 h-10 rounded-xl bg-[#1B5E7B]/10 flex items-center justify-center text-[#1B5E7B] font-black flex-shrink-0">
                    {{ mb_substr($appointment->therapist->full_name ?? '؟', 0, 1) }}
                </div>
                <div>
                    <div class="font-semibold text-sm">{{ $appointment->therapist->full_name ?? '—' }}</div>
                    <div class="text-xs text-[#1B5E7B]">عرض الملف ↗</div>
                </div>
            </a>
        </div>

        {{-- Patient --}}
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
            <h3 class="font-bold text-sm text-gray-700 mb-3">المريض</h3>
            <a href="{{ route('admin.patients.show', $appointment->patient->user) }}"
               class="flex items-center gap-3 hover:bg-gray-50 p-2 rounded-xl transition-colors -m-2">
                <div class="w-10 h-10 rounded-xl flex items-center justify-center text-white font-black flex-shrink-0"
                     style="background:linear-gradient(135deg,#1B2E6E,#2D4A9E)">
                    {{ mb_substr($appointment->patient->full_name ?? '؟', 0, 1) }}
                </div>
                <div>
                    <div class="font-semibold text-sm">{{ $appointment->patient->full_name ?? '—' }}</div>
                    <div class="text-xs text-[#1B2E6E]">عرض الملف ↗</div>
                </div>
            </a>
        </div>
    </div>

    {{-- Actions --}}
    <div class="lg:col-span-2 space-y-5">

        {{-- Change Status --}}
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
            <h3 class="font-bold text-sm text-gray-700 mb-4">تغيير حالة الموعد</h3>
            <form method="POST" action="{{ route('admin.appointments.status', $appointment) }}" class="space-y-4">
                @csrf
                <div class="grid grid-cols-2 sm:grid-cols-4 gap-2">
                    @foreach([
                        'pending'            => ['label' => 'معلق',      'cls' => 'border-yellow-200 text-yellow-700 hover:bg-yellow-50'],
                        'confirmed'          => ['label' => 'مؤكد',      'cls' => 'border-blue-200 text-blue-700 hover:bg-blue-50'],
                        'completed'          => ['label' => 'مكتمل',     'cls' => 'border-green-200 text-green-700 hover:bg-green-50'],
                        'cancelled_by_admin' => ['label' => 'ملغى (إدارة)', 'cls' => 'border-red-200 text-red-700 hover:bg-red-50'],
                    ] as $val => $meta)
                        <label class="flex flex-col items-center cursor-pointer border rounded-xl px-3 py-3 transition-all {{ $meta['cls'] }} {{ $appointment->status === $val ? 'ring-2 ring-offset-1 ring-current font-bold' : '' }}">
                            <input type="radio" name="status" value="{{ $val }}"
                                   {{ $appointment->status === $val ? 'checked' : '' }}
                                   class="sr-only">
                            <span class="text-sm font-semibold">{{ $meta['label'] }}</span>
                        </label>
                    @endforeach
                </div>
                <div>
                    <label class="text-xs text-gray-500 font-semibold block mb-1">ملاحظة (اختياري — سترسل للطرفين)</label>
                    <textarea name="note" rows="2" placeholder="سبب التغيير..."
                              class="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm focus:outline-none resize-none"></textarea>
                </div>
                <div class="flex gap-3">
                    <button type="submit"
                            class="bg-[#1B5E7B] hover:bg-[#154d66] text-white font-bold px-6 py-2.5 rounded-xl text-sm">
                        💾 حفظ الحالة وإشعار الطرفين
                    </button>
                    <form method="POST" action="{{ route('admin.appointments.destroy', $appointment) }}"
                          onsubmit="return confirm('هل أنت متأكد من حذف هذا الموعد؟')">
                        @csrf @method('DELETE')
                        <button type="submit" class="bg-red-50 hover:bg-red-100 text-red-600 font-semibold px-5 py-2.5 rounded-xl text-sm">
                            🗑️ حذف
                        </button>
                    </form>
                </div>
            </form>
        </div>

        {{-- Notes / Additional Info --}}
        @if($appointment->notes ?? $appointment->chief_complaint ?? $appointment->cancellation_reason)
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
                <h3 class="font-bold text-sm text-gray-700 mb-3">ملاحظات</h3>
                @if($appointment->chief_complaint)
                    <p class="text-xs text-gray-500 font-semibold mb-1">الشكوى الرئيسية</p>
                    <p class="text-sm text-gray-700 mb-3">{{ $appointment->chief_complaint }}</p>
                @endif
                @if($appointment->notes)
                    <p class="text-xs text-gray-500 font-semibold mb-1">الملاحظات</p>
                    <p class="text-sm text-gray-700 mb-3">{{ $appointment->notes }}</p>
                @endif
                @if($appointment->cancellation_reason)
                    <p class="text-xs text-gray-500 font-semibold mb-1">سبب الإلغاء</p>
                    <p class="text-sm text-red-600">{{ $appointment->cancellation_reason }}</p>
                @endif
            </div>
        @endif

    </div>
</div>

<script>
// Make radio buttons visually toggle on click
document.querySelectorAll('input[name="status"]').forEach(radio => {
    radio.addEventListener('change', () => {
        document.querySelectorAll('label[class*="border-"]').forEach(l => l.classList.remove('ring-2','ring-offset-1','ring-current','font-bold'));
        if (radio.checked) {
            radio.closest('label').classList.add('ring-2','ring-offset-1','ring-current','font-bold');
        }
    });
});
</script>
@endsection
