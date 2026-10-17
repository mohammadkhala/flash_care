@extends('layouts.admin')
@section('title', 'قالب: ' . $template->name_ar)
@section('subtitle', $template->name_en)

@php
    $input = 'w-full border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:border-[#1B5E7B] focus:ring-2 focus:ring-[#1B5E7B]/20';
    $label = 'block text-xs font-semibold text-gray-600 mb-1';
    $selected = $template->sections->pluck('pivot.sort', 'id');
@endphp

@section('content')

<a href="{{ route('admin.assessments.index') }}" class="inline-block text-sm text-[#1B5E7B] mb-4">→ رجوع إلى قوالب التقييم</a>

@if($errors->any())
    <div class="mb-4 bg-red-50 text-red-600 text-sm rounded-xl p-3">{{ $errors->first() }}</div>
@endif

<form method="POST" action="{{ route('admin.assessments.templates.update', $template) }}" class="grid grid-cols-1 xl:grid-cols-3 gap-6">
    @csrf @method('PUT')

    <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5 space-y-3 h-fit">
        <h3 class="font-bold text-gray-800 mb-2">بيانات القالب</h3>
        <div><label class="{{ $label }}">الاسم بالعربية *</label><input name="name_ar" value="{{ $template->name_ar }}" required class="{{ $input }}"></div>
        <div><label class="{{ $label }}">الاسم بالإنجليزية * (عنوان التقرير)</label><input name="name_en" value="{{ $template->name_en }}" required dir="ltr" class="{{ $input }}"></div>
        <div><label class="{{ $label }}">وصف</label><input name="description" value="{{ $template->description }}" class="{{ $input }}"></div>
        <div><label class="{{ $label }}">ترتيب القالب</label><input name="sort" value="{{ $template->sort }}" type="number" class="{{ $input }}"></div>
        <label class="flex items-center gap-2 text-sm"><input type="checkbox" name="is_active" value="1" @checked($template->is_active)> نشط (يظهر للأخصائيين)</label>
        <button class="w-full bg-[#1B5E7B] text-white font-bold py-2.5 rounded-xl text-sm hover:bg-[#154d66]">حفظ القالب</button>
    </div>

    <div class="xl:col-span-2 bg-white rounded-2xl border border-gray-100 shadow-sm">
        <div class="p-5 border-b border-gray-100">
            <h3 class="font-bold text-gray-800">أقسام القالب</h3>
            <p class="text-xs text-gray-400 mt-1">اختر التصنيفات التي تظهر في هذا القالب، والرقم = ترتيبها في التقرير.</p>
        </div>
        <div class="divide-y divide-gray-50">
            @foreach($sections as $s)
                <label class="px-5 py-3 flex items-center gap-3 hover:bg-gray-50 cursor-pointer">
                    <input type="checkbox" name="sections[]" value="{{ $s->id }}" @checked($selected->has($s->id))>
                    <input type="number" name="order[{{ $s->id }}]" value="{{ $selected[$s->id] ?? $loop->iteration }}" min="0"
                           class="w-16 border border-gray-200 rounded-lg px-2 py-1 text-sm">
                    <div class="flex-1">
                        <div class="font-semibold text-sm text-gray-800">{{ $s->name_ar }}
                            @unless($s->is_active)<span class="text-xs text-gray-400">(موقوف)</span>@endunless
                        </div>
                        <div class="text-xs text-gray-400" dir="ltr">{{ $s->name_en }} · {{ $s->items_count }} items</div>
                    </div>
                    <a href="{{ route('admin.assessments.sections.edit', $s) }}" class="text-xs text-[#1B5E7B]">تعديل البنود</a>
                </label>
            @endforeach
        </div>
    </div>
</form>

<form method="POST" action="{{ route('admin.assessments.templates.destroy', $template) }}" class="mt-6"
      onsubmit="return confirm('حذف القالب؟ التقارير المحفوظة لا تتأثر. يُفضّل الإيقاف بدل الحذف.')">
    @csrf @method('DELETE')
    <button class="text-xs bg-red-50 text-red-500 hover:bg-red-100 px-4 py-2 rounded-lg">حذف القالب</button>
</form>
@endsection
