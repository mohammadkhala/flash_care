@extends('layouts.admin')
@section('title', 'قوالب التقييم')
@section('subtitle', 'تقارير المرضى: الأدمن يحدد الأقسام والبنود — الأخصائي يُدخل القيم فقط')

@php
    $input = 'w-full border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:border-[#1B5E7B] focus:ring-2 focus:ring-[#1B5E7B]/20';
    $label = 'block text-xs font-semibold text-gray-600 mb-1';
@endphp

@section('content')

<div class="bg-blue-50 border border-blue-100 text-blue-800 text-sm rounded-2xl p-4 mb-6 leading-7">
    <b>كيف يعمل:</b>
    <b>التصنيف</b> = جدول في التقرير (مثل ROM أو MMT) وله بنود (الحركات / العضلات) مع المدى الطبيعي.
    <b>القالب</b> = مجموعة تصنيفات بترتيب يختارها الأخصائي عند إنشاء التقرير.
    التعديل هنا لا يغيّر التقارير المحفوظة ({{ $reportsCount }} تقرير) — كل تقرير يحتفظ بنسخته.
</div>

<div class="grid grid-cols-1 xl:grid-cols-2 gap-6">

    {{-- Templates --}}
    <div class="bg-white rounded-2xl border border-gray-100 shadow-sm">
        <div class="p-5 border-b border-gray-100 flex items-center justify-between">
            <h3 class="font-bold text-gray-800">القوالب ({{ $templates->count() }})</h3>
        </div>
        <div class="divide-y divide-gray-50">
            @forelse($templates as $t)
                <a href="{{ route('admin.assessments.templates.edit', $t) }}" class="px-5 py-3 flex items-center justify-between hover:bg-gray-50">
                    <div>
                        <div class="font-semibold text-sm text-gray-800">{{ $t->name_ar }}</div>
                        <div class="text-xs text-gray-400" dir="ltr">{{ $t->name_en }} · {{ $t->sections_count }} sections</div>
                    </div>
                    <span @class(['text-xs px-2 py-1 rounded-full font-semibold',
                        'bg-green-50 text-green-600' => $t->is_active, 'bg-gray-100 text-gray-400' => !$t->is_active])>
                        {{ $t->is_active ? 'نشط' : 'موقوف' }}</span>
                </a>
            @empty
                <div class="text-center py-8 text-gray-400 text-sm">لا توجد قوالب</div>
            @endforelse
        </div>
        <form method="POST" action="{{ route('admin.assessments.templates.store') }}" class="p-5 border-t border-gray-100 space-y-3 bg-gray-50/50 rounded-b-2xl">
            @csrf
            <div class="font-semibold text-sm text-gray-700">+ قالب جديد</div>
            <div class="grid grid-cols-2 gap-3">
                <div><label class="{{ $label }}">الاسم بالعربية *</label><input name="name_ar" required class="{{ $input }}" placeholder="تقييم الكتف"></div>
                <div><label class="{{ $label }}">الاسم بالإنجليزية *</label><input name="name_en" required dir="ltr" class="{{ $input }}" placeholder="Shoulder Assessment"></div>
            </div>
            <div><label class="{{ $label }}">وصف (اختياري)</label><input name="description" class="{{ $input }}"></div>
            <button class="bg-[#1B5E7B] text-white font-bold px-5 py-2 rounded-xl text-sm hover:bg-[#154d66]">إضافة القالب</button>
        </form>
    </div>

    {{-- Sections --}}
    <div class="bg-white rounded-2xl border border-gray-100 shadow-sm">
        <div class="p-5 border-b border-gray-100">
            <h3 class="font-bold text-gray-800">التصنيفات ({{ $sections->count() }})</h3>
        </div>
        <div class="divide-y divide-gray-50">
            @forelse($sections as $s)
                <a href="{{ route('admin.assessments.sections.edit', $s) }}" class="px-5 py-3 flex items-center justify-between hover:bg-gray-50">
                    <div>
                        <div class="font-semibold text-sm text-gray-800">{{ $s->name_ar }}</div>
                        <div class="text-xs text-gray-400" dir="ltr">{{ $s->name_en }} · {{ $s->items_count }} items</div>
                        <div class="text-[11px] text-gray-400 mt-0.5">{{ $types[$s->type] ?? $s->type }}</div>
                    </div>
                    <span @class(['text-xs px-2 py-1 rounded-full font-semibold',
                        'bg-green-50 text-green-600' => $s->is_active, 'bg-gray-100 text-gray-400' => !$s->is_active])>
                        {{ $s->is_active ? 'نشط' : 'موقوف' }}</span>
                </a>
            @empty
                <div class="text-center py-8 text-gray-400 text-sm">لا توجد تصنيفات</div>
            @endforelse
        </div>
        <form method="POST" action="{{ route('admin.assessments.sections.store') }}" class="p-5 border-t border-gray-100 space-y-3 bg-gray-50/50 rounded-b-2xl"
              x-data="{ type: 'bilateral_number' }">
            @csrf
            <div class="font-semibold text-sm text-gray-700">+ تصنيف جديد</div>
            <div class="grid grid-cols-2 gap-3">
                <div><label class="{{ $label }}">الاسم بالعربية *</label><input name="name_ar" required class="{{ $input }}" placeholder="مدى الحركة — الكتف"></div>
                <div><label class="{{ $label }}">الاسم بالإنجليزية *</label><input name="name_en" required dir="ltr" class="{{ $input }}" placeholder="Range of Motion (ROM)"></div>
            </div>
            <div>
                <label class="{{ $label }}">نوع الجدول *</label>
                <select name="type" x-model="type" class="{{ $input }}">
                    @foreach($types as $k => $v)<option value="{{ $k }}">{{ $v }}</option>@endforeach
                </select>
            </div>
            <div class="grid grid-cols-3 gap-3" x-show="type !== 'text' && type !== 'pos_neg'">
                <div><label class="{{ $label }}">الوحدة</label><input name="unit" dir="ltr" class="{{ $input }}" placeholder="° أو /5 أو cm"></div>
                <div x-show="type === 'bilateral_grade' || type === 'single_number'"><label class="{{ $label }}">أقل قيمة</label><input name="scale_min" type="number" step="any" class="{{ $input }}" placeholder="0"></div>
                <div x-show="type === 'bilateral_grade' || type === 'single_number'"><label class="{{ $label }}">أعلى قيمة</label><input name="scale_max" type="number" step="any" class="{{ $input }}" placeholder="5"></div>
            </div>
            <button class="bg-[#1B5E7B] text-white font-bold px-5 py-2 rounded-xl text-sm hover:bg-[#154d66]">إضافة التصنيف</button>
        </form>
    </div>
</div>

@if($errors->any())
    <div class="mt-4 bg-red-50 text-red-600 text-sm rounded-xl p-3">{{ $errors->first() }}</div>
@endif
@endsection
