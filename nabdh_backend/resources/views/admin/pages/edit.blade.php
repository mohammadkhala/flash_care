@extends('layouts.admin')
@section('title', 'تعديل: ' . $page->title_ar)

@section('content')

@if(session('success'))
<div class="mb-4 p-4 bg-green-50 border border-green-200 text-green-700 rounded-xl text-sm font-semibold">
    ✓ {{ session('success') }}
</div>
@endif

<div class="max-w-4xl">
    <div class="flex items-center gap-3 mb-6">
        <a href="{{ route('admin.pages.index') }}" class="text-gray-400 hover:text-gray-600 transition-colors">
            ← العودة
        </a>
        <h1 class="text-lg font-bold text-gray-800">
            {{ $page->slug === 'terms' ? '📋' : '🔒' }} {{ $page->title_ar }}
        </h1>
    </div>

    <form method="POST" action="{{ route('admin.pages.update', $page->slug) }}">
        @csrf
        @method('PUT')

        {{-- Titles --}}
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 mb-6">
            <h2 class="font-bold text-gray-800 mb-4 text-sm">العناوين</h2>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
                    <label class="block text-xs font-semibold text-gray-600 mb-1.5">العنوان بالعربية *</label>
                    <input type="text" name="title_ar" value="{{ old('title_ar', $page->title_ar) }}" required
                        class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-[#1B5E7B]/30">
                </div>
                <div>
                    <label class="block text-xs font-semibold text-gray-600 mb-1.5">English Title</label>
                    <input type="text" name="title_en" value="{{ old('title_en', $page->title_en) }}"
                        class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-[#1B5E7B]/30">
                </div>
                <div>
                    <label class="block text-xs font-semibold text-gray-600 mb-1.5">עברית כותרת</label>
                    <input type="text" name="title_he" value="{{ old('title_he', $page->title_he) }}"
                        class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-[#1B5E7B]/30">
                </div>
            </div>
        </div>

        {{-- Tabs for language content --}}
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 mb-6"
             x-data="{ lang: 'ar' }">
            <div class="flex items-center justify-between mb-4">
                <h2 class="font-bold text-gray-800 text-sm">المحتوى</h2>
                <div class="flex gap-1 bg-gray-100 p-1 rounded-xl">
                    <button type="button" @click="lang='ar'"
                        :class="lang==='ar' ? 'bg-white shadow text-[#1B5E7B] font-bold' : 'text-gray-500'"
                        class="px-4 py-1.5 rounded-lg text-xs transition-all">عربي</button>
                    <button type="button" @click="lang='en'"
                        :class="lang==='en' ? 'bg-white shadow text-[#1B5E7B] font-bold' : 'text-gray-500'"
                        class="px-4 py-1.5 rounded-lg text-xs transition-all">English</button>
                    <button type="button" @click="lang='he'"
                        :class="lang==='he' ? 'bg-white shadow text-[#1B5E7B] font-bold' : 'text-gray-500'"
                        class="px-4 py-1.5 rounded-lg text-xs transition-all">עברית</button>
                </div>
            </div>

            <div x-show="lang==='ar'">
                <p class="text-xs text-gray-400 mb-2">يدعم HTML (h2، h3، p، ul، li، strong)</p>
                <textarea name="content_ar" rows="18" dir="rtl"
                    class="w-full border border-gray-200 rounded-xl px-4 py-3 text-sm font-mono focus:outline-none focus:ring-2 focus:ring-[#1B5E7B]/30 resize-y">{{ old('content_ar', $page->content_ar) }}</textarea>
            </div>
            <div x-show="lang==='en'" style="display:none">
                <textarea name="content_en" rows="18" dir="ltr"
                    class="w-full border border-gray-200 rounded-xl px-4 py-3 text-sm font-mono focus:outline-none focus:ring-2 focus:ring-[#1B5E7B]/30 resize-y">{{ old('content_en', $page->content_en) }}</textarea>
            </div>
            <div x-show="lang==='he'" style="display:none">
                <textarea name="content_he" rows="18" dir="rtl"
                    class="w-full border border-gray-200 rounded-xl px-4 py-3 text-sm font-mono focus:outline-none focus:ring-2 focus:ring-[#1B5E7B]/30 resize-y">{{ old('content_he', $page->content_he) }}</textarea>
            </div>
        </div>

        {{-- Status --}}
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5 mb-6">
            <label class="flex items-center gap-3 cursor-pointer">
                <div class="relative">
                    <input type="hidden" name="is_active" value="0">
                    <input type="checkbox" name="is_active" value="1"
                        {{ $page->is_active ? 'checked' : '' }}
                        class="sr-only peer">
                    <div class="w-11 h-6 bg-gray-200 rounded-full peer-checked:bg-[#1B5E7B] transition-colors"></div>
                    <div class="absolute top-0.5 left-0.5 w-5 h-5 bg-white rounded-full shadow transition-transform peer-checked:translate-x-5"></div>
                </div>
                <div>
                    <span class="text-sm font-semibold text-gray-700">الصفحة نشطة</span>
                    <p class="text-xs text-gray-400">إذا كانت غير نشطة، لن تظهر في التطبيقين</p>
                </div>
            </label>
        </div>

        <button type="submit"
            class="bg-[#1B5E7B] hover:bg-[#0F4459] text-white font-bold py-3 px-8 rounded-xl transition-colors text-sm">
            💾 حفظ التغييرات
        </button>
    </form>
</div>

@endsection
