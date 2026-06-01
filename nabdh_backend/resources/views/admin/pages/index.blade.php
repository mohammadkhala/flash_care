@extends('layouts.admin')
@section('title', 'الصفحات')

@section('content')

<div class="grid grid-cols-1 md:grid-cols-2 gap-6">
    @foreach($pages as $page)
    <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
        <div class="flex items-start justify-between mb-4">
            <div>
                <div class="flex items-center gap-2 mb-1">
                    <span class="text-2xl">{{ $page->slug === 'terms' ? '📋' : '🔒' }}</span>
                    <h3 class="font-bold text-gray-800 text-base">{{ $page->title_ar }}</h3>
                </div>
                <span class="text-xs text-gray-400">آخر تحديث: {{ $page->updated_at->diffForHumans() }}</span>
            </div>
            <span class="text-xs px-3 py-1 rounded-full font-semibold
                {{ $page->is_active ? 'bg-green-50 text-green-700 border border-green-100' : 'bg-gray-50 text-gray-500 border border-gray-100' }}">
                {{ $page->is_active ? 'نشط' : 'مخفي' }}
            </span>
        </div>
        <p class="text-sm text-gray-500 mb-4 line-clamp-2">
            {{ strip_tags(substr($page->content_ar, 0, 150)) }}...
        </p>
        <a href="{{ route('admin.pages.edit', $page->slug) }}"
           class="inline-flex items-center gap-2 bg-[#1B5E7B] hover:bg-[#0F4459] text-white text-sm font-semibold px-5 py-2.5 rounded-xl transition-colors">
            ✏️ تعديل المحتوى
        </a>
    </div>
    @endforeach
</div>

@endsection
