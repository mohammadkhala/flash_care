@extends('layouts.admin')
@section('title', 'التخصصات')

@section('content')

<div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

    {{-- Add New --}}
    <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
        <h3 class="font-bold text-gray-800 mb-5">إضافة تخصص جديد</h3>
        <form method="POST" action="{{ route('admin.specializations.store') }}" class="space-y-4">
            @csrf
            <div>
                <label class="block text-xs font-semibold text-gray-600 mb-2">الاسم بالعربية *</label>
                <input type="text" name="name_ar" required
                       class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:border-[#1B5E7B] focus:ring-2 focus:ring-[#1B5E7B]/20"
                       placeholder="علاج طبيعي عام">
            </div>
            <div>
                <label class="block text-xs font-semibold text-gray-600 mb-2">الاسم بالإنجليزية *</label>
                <input type="text" name="name_en" required dir="ltr"
                       class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:border-[#1B5E7B] focus:ring-2 focus:ring-[#1B5E7B]/20"
                       placeholder="General Physical Therapy">
            </div>
            <button class="w-full bg-[#1B5E7B] text-white font-bold py-3 rounded-xl hover:bg-[#154d66] transition-colors text-sm">
                + إضافة التخصص
            </button>
        </form>
    </div>

    {{-- List --}}
    <div class="lg:col-span-2 bg-white rounded-2xl border border-gray-100 shadow-sm">
        <div class="p-5 border-b border-gray-100">
            <h3 class="font-bold text-gray-800">التخصصات الحالية ({{ $specializations->count() }})</h3>
        </div>
        <div class="divide-y divide-gray-50">
            @forelse($specializations as $spec)
                <div class="px-5 py-4 flex items-center justify-between" x-data="{ editing: false }">
                    <div x-show="!editing" class="flex items-center gap-3">
                        <div class="w-9 h-9 rounded-xl bg-blue-50 flex items-center justify-center text-blue-600 text-sm font-bold">
                            {{ mb_substr($spec->name_ar, 0, 1) }}
                        </div>
                        <div>
                            <div class="font-semibold text-sm text-gray-800">{{ $spec->name_ar }}</div>
                            <div class="text-xs text-gray-400">{{ $spec->name_en }} · {{ $spec->therapists_count }} أخصائي</div>
                        </div>
                    </div>

                    {{-- Edit form --}}
                    <form x-show="editing" x-transition method="POST" action="{{ route('admin.specializations.update', $spec) }}" class="flex gap-2 flex-1 ml-3">
                        @csrf @method('PUT')
                        <input type="text" name="name_ar" value="{{ $spec->name_ar }}" required
                               class="flex-1 border border-gray-200 rounded-xl px-3 py-1.5 text-sm focus:outline-none focus:border-[#1B5E7B]">
                        <input type="text" name="name_en" value="{{ $spec->name_en }}" required dir="ltr"
                               class="flex-1 border border-gray-200 rounded-xl px-3 py-1.5 text-sm focus:outline-none focus:border-[#1B5E7B]">
                        <button class="bg-green-500 text-white text-xs font-bold px-3 py-1.5 rounded-lg">حفظ</button>
                    </form>

                    <div class="flex items-center gap-2 mr-auto">
                        <span @class([
                            'text-xs px-2 py-1 rounded-full font-semibold',
                            'bg-green-50 text-green-600' => $spec->is_active,
                            'bg-gray-100 text-gray-400' => !$spec->is_active,
                        ])>{{ $spec->is_active ? 'نشط' : 'موقوف' }}</span>

                        <button @click="editing = !editing"
                                class="text-xs bg-gray-100 hover:bg-gray-200 text-gray-600 px-3 py-1.5 rounded-lg transition-colors">
                            تعديل
                        </button>
                        <form method="POST" action="{{ route('admin.specializations.toggle', $spec) }}">
                            @csrf
                            <button class="text-xs {{ $spec->is_active ? 'bg-red-50 text-red-500 hover:bg-red-100' : 'bg-green-50 text-green-500 hover:bg-green-100' }} px-3 py-1.5 rounded-lg transition-colors">
                                {{ $spec->is_active ? 'إيقاف' : 'تفعيل' }}
                            </button>
                        </form>
                    </div>
                </div>
            @empty
                <div class="text-center py-10 text-gray-400 text-sm">لا توجد تخصصات</div>
            @endforelse
        </div>
    </div>
</div>
@endsection
