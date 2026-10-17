@extends('layouts.admin')
@section('title', 'تصنيف: ' . $section->name_ar)
@section('subtitle', $section->name_en)

@php
    $input = 'w-full border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:border-[#1B5E7B] focus:ring-2 focus:ring-[#1B5E7B]/20';
    $cell  = 'w-full border border-gray-200 rounded-lg px-2 py-1.5 text-sm focus:outline-none focus:border-[#1B5E7B]';
    $label = 'block text-xs font-semibold text-gray-600 mb-1';
    $hasRange = $section->hasNormalRange();
@endphp

@section('content')

<a href="{{ route('admin.assessments.index') }}" class="inline-block text-sm text-[#1B5E7B] mb-4">→ رجوع إلى قوالب التقييم</a>

@if($errors->any())
    <div class="mb-4 bg-red-50 text-red-600 text-sm rounded-xl p-3">{{ $errors->first() }}</div>
@endif

<div class="grid grid-cols-1 xl:grid-cols-3 gap-6">

    {{-- Section settings --}}
    <form method="POST" action="{{ route('admin.assessments.sections.update', $section) }}"
          class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5 space-y-3 h-fit" x-data="{ type: '{{ $section->type }}' }">
        @csrf @method('PUT')
        <h3 class="font-bold text-gray-800 mb-2">إعدادات التصنيف</h3>
        <div><label class="{{ $label }}">الاسم بالعربية *</label><input name="name_ar" value="{{ $section->name_ar }}" required class="{{ $input }}"></div>
        <div><label class="{{ $label }}">الاسم بالإنجليزية * (يظهر في التقرير)</label><input name="name_en" value="{{ $section->name_en }}" required dir="ltr" class="{{ $input }}"></div>
        <div>
            <label class="{{ $label }}">نوع الجدول</label>
            <select name="type" x-model="type" class="{{ $input }}">
                @foreach($types as $k => $v)<option value="{{ $k }}" @selected($section->type === $k)>{{ $v }}</option>@endforeach
            </select>
        </div>
        <div class="grid grid-cols-3 gap-2" x-show="type !== 'text' && type !== 'pos_neg'">
            <div><label class="{{ $label }}">الوحدة</label><input name="unit" value="{{ $section->unit }}" dir="ltr" class="{{ $input }}"></div>
            <div x-show="type === 'bilateral_grade' || type === 'single_number'"><label class="{{ $label }}">أقل</label><input name="scale_min" value="{{ $section->scale_min }}" type="number" step="any" class="{{ $input }}"></div>
            <div x-show="type === 'bilateral_grade' || type === 'single_number'"><label class="{{ $label }}">أعلى</label><input name="scale_max" value="{{ $section->scale_max }}" type="number" step="any" class="{{ $input }}"></div>
        </div>
        <div><label class="{{ $label }}">الترتيب</label><input name="sort" value="{{ $section->sort }}" type="number" class="{{ $input }}"></div>
        <label class="flex items-center gap-2 text-sm"><input type="checkbox" name="is_active" value="1" @checked($section->is_active)> نشط (يظهر للأخصائيين)</label>
        <button class="w-full bg-[#1B5E7B] text-white font-bold py-2.5 rounded-xl text-sm hover:bg-[#154d66]">حفظ</button>
    </form>

    {{-- Items --}}
    <div class="xl:col-span-2 bg-white rounded-2xl border border-gray-100 shadow-sm">
        <div class="p-5 border-b border-gray-100">
            <h3 class="font-bold text-gray-800">البنود ({{ $section->items->count() }})</h3>
            <p class="text-xs text-gray-400 mt-1">
                @if($hasRange)
                    المدى الطبيعي: القيمة التي يُدخلها الأخصائي خارج (من–إلى) تظهر بالأحمر في التقرير.
                    @if($section->type === 'bilateral_grade') للقوة الطبيعية ضع من 5 إلى 5. @endif
                @elseif($section->type === 'pos_neg')
                    الأخصائي يختار إيجابي / سلبي لكل جهة. الإيجابي يظهر بالأحمر.
                @else
                    كل بند = حقل نص يكتب فيه الأخصائي.
                @endif
            </p>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead class="bg-gray-50 text-xs text-gray-500">
                <tr>
                    <th class="p-2 text-right w-14">ترتيب</th>
                    <th class="p-2 text-right">الاسم بالإنجليزية</th>
                    <th class="p-2 text-right">بالعربية</th>
                    @if($hasRange)<th class="p-2 text-right w-20">من</th><th class="p-2 text-right w-20">إلى</th>@endif
                    <th class="p-2 w-14">نشط</th>
                    <th class="p-2 w-36"></th>
                </tr>
                </thead>
                <tbody class="divide-y divide-gray-50">
                @foreach($section->items as $item)
                    <tr>
                        <td class="p-1.5" colspan="{{ $hasRange ? 6 : 4 }}">
                            <form method="POST" action="{{ route('admin.assessments.items.update', $item) }}" class="flex items-center gap-1.5">
                                @csrf @method('PUT')
                                <input name="sort" value="{{ $item->sort }}" type="number" class="{{ $cell }} !w-14">
                                <input name="name_en" value="{{ $item->name_en }}" required dir="ltr" class="{{ $cell }}">
                                <input name="name_ar" value="{{ $item->name_ar }}" class="{{ $cell }}">
                                @if($hasRange)
                                    <input name="normal_min" value="{{ $item->normal_min }}" type="number" step="any" class="{{ $cell }} !w-20">
                                    <input name="normal_max" value="{{ $item->normal_max }}" type="number" step="any" class="{{ $cell }} !w-20">
                                @endif
                                <input type="checkbox" name="is_active" value="1" @checked($item->is_active) class="mx-3">
                                <button class="bg-green-500 text-white text-xs font-bold px-3 py-1.5 rounded-lg">حفظ</button>
                            </form>
                        </td>
                        <td class="p-1.5 w-14">
                            <form method="POST" action="{{ route('admin.assessments.items.destroy', $item) }}" onsubmit="return confirm('حذف البند؟')">
                                @csrf @method('DELETE')
                                <button class="bg-red-50 text-red-500 text-xs px-3 py-1.5 rounded-lg">حذف</button>
                            </form>
                        </td>
                    </tr>
                @endforeach
                </tbody>
            </table>
        </div>

        <form method="POST" action="{{ route('admin.assessments.items.store', $section) }}" class="p-4 border-t border-gray-100 bg-gray-50/50 rounded-b-2xl flex flex-wrap items-end gap-2">
            @csrf
            <div class="flex-1 min-w-[160px]"><label class="{{ $label }}">بند جديد — بالإنجليزية *</label><input name="name_en" required dir="ltr" class="{{ $input }}" placeholder="Shoulder Flexion"></div>
            <div class="flex-1 min-w-[140px]"><label class="{{ $label }}">بالعربية</label><input name="name_ar" class="{{ $input }}" placeholder="ثني الكتف"></div>
            @if($hasRange)
                <div class="w-24"><label class="{{ $label }}">طبيعي من</label><input name="normal_min" type="number" step="any" class="{{ $input }}" placeholder="0"></div>
                <div class="w-24"><label class="{{ $label }}">إلى</label><input name="normal_max" type="number" step="any" class="{{ $input }}" placeholder="180"></div>
            @endif
            <button class="bg-[#1B5E7B] text-white font-bold px-5 py-2 rounded-xl text-sm hover:bg-[#154d66]">+ إضافة</button>
        </form>
    </div>
</div>

<form method="POST" action="{{ route('admin.assessments.sections.destroy', $section) }}" class="mt-6"
      onsubmit="return confirm('حذف التصنيف وكل بنوده؟ التقارير المحفوظة لا تتأثر. يُفضّل الإيقاف بدل الحذف.')">
    @csrf @method('DELETE')
    <button class="text-xs bg-red-50 text-red-500 hover:bg-red-100 px-4 py-2 rounded-lg">حذف التصنيف</button>
</form>
@endsection
