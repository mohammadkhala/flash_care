@extends('layouts.admin')
@section('title', 'الريلز')

@section('content')

{{-- Filter Tabs --}}
<div class="flex items-center gap-2 mb-5 bg-white rounded-2xl p-2 border border-gray-100 shadow-sm w-fit">
    @foreach(['all' => 'الكل', 'pending' => 'بانتظار المراجعة', 'approved' => 'منشور', 'rejected' => 'مرفوض'] as $val => $label)
        <a href="{{ route('admin.reels.index', ['status' => $val === 'all' ? null : $val]) }}"
           class="px-4 py-2 rounded-xl text-sm font-semibold transition-all
                  {{ (request('status', 'all') === $val) ? 'bg-[#1B5E7B] text-white shadow' : 'text-gray-600 hover:bg-gray-50' }}">
            {{ $label }}
        </a>
    @endforeach
</div>

{{-- Grid --}}
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
    @forelse($reels as $reel)
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden" x-data="{ rejectOpen: false }">
            {{-- Thumbnail --}}
            <div class="relative aspect-video bg-gray-100">
                @if($reel->thumbnail_url)
                    <img src="{{ $reel->full_thumbnail_url }}" class="w-full h-full object-cover">
                @else
                    <div class="w-full h-full flex items-center justify-center text-4xl text-gray-300">🎬</div>
                @endif
                <span @class([
                    'absolute top-2 left-2 text-xs font-bold px-2 py-1 rounded-full',
                    'bg-yellow-400 text-yellow-900' => $reel->status === 'pending',
                    'bg-green-500 text-white' => $reel->status === 'approved',
                    'bg-red-500 text-white' => $reel->status === 'rejected',
                ])>
                    {{ match($reel->status) { 'pending' => 'معلق', 'approved' => 'منشور', 'rejected' => 'مرفوض' } }}
                </span>
                @if($reel->duration_seconds)
                    <span class="absolute bottom-2 left-2 bg-black/60 text-white text-xs px-2 py-0.5 rounded">
                        {{ gmdate('i:s', $reel->duration_seconds) }}
                    </span>
                @endif
            </div>

            <div class="p-4">
                <h3 class="font-bold text-sm text-gray-800 mb-1 truncate">{{ $reel->title }}</h3>
                <div class="flex items-center gap-1 mb-3">
                    <div class="w-5 h-5 rounded-full bg-[#1B5E7B]/10 flex items-center justify-center text-xs text-[#1B5E7B] font-bold">
                        {{ mb_substr($reel->therapist->full_name, 0, 1) }}
                    </div>
                    <span class="text-xs text-gray-500">{{ $reel->therapist->full_name }}</span>
                </div>
                <div class="flex items-center gap-3 text-xs text-gray-400 mb-3">
                    <span>👁 {{ number_format($reel->views) }}</span>
                    <span>❤️ {{ number_format($reel->likes_count) }}</span>
                    <span>{{ $reel->created_at->diffForHumans() }}</span>
                </div>

                {{-- Actions --}}
                @if($reel->status === 'pending')
                    <div class="flex gap-2">
                        <form method="POST" action="{{ route('admin.reels.approve', $reel) }}" class="flex-1">
                            @csrf
                            <button class="w-full bg-green-500 hover:bg-green-600 text-white text-xs font-bold py-2 rounded-xl transition-colors">
                                ✓ نشر
                            </button>
                        </form>
                        <button @click="rejectOpen = !rejectOpen"
                                class="flex-1 bg-red-50 hover:bg-red-100 text-red-600 text-xs font-bold py-2 rounded-xl transition-colors border border-red-100">
                            ✕ رفض
                        </button>
                    </div>
                    <div x-show="rejectOpen" x-transition class="mt-3">
                        <form method="POST" action="{{ route('admin.reels.reject', $reel) }}" class="space-y-2">
                            @csrf
                            <textarea name="reason" rows="2" required placeholder="سبب الرفض..."
                                      class="w-full border border-gray-200 rounded-xl px-3 py-2 text-xs focus:outline-none focus:border-red-400"></textarea>
                            <button class="w-full bg-red-500 text-white text-xs font-bold py-2 rounded-xl">إرسال</button>
                        </form>
                    </div>
                @else
                    <div class="flex gap-2">
                        @if($reel->video_url)
                            <a href="{{ $reel->full_video_url }}" target="_blank"
                               class="flex-1 text-center bg-blue-50 text-blue-600 text-xs font-bold py-2 rounded-xl border border-blue-100 hover:bg-blue-100 transition-colors">
                                ▶ مشاهدة
                            </a>
                        @endif
                        <form method="POST" action="{{ route('admin.reels.destroy', $reel) }}" class="flex-1"
                              onsubmit="return confirm('هل تريد حذف هذا الريل؟')">
                            @csrf @method('DELETE')
                            <button class="w-full bg-gray-50 hover:bg-red-50 text-gray-500 hover:text-red-600 text-xs font-bold py-2 rounded-xl border border-gray-200 transition-colors">
                                🗑 حذف
                            </button>
                        </form>
                    </div>
                @endif
            </div>
        </div>
    @empty
        <div class="col-span-full text-center py-20 text-gray-400">
            <div class="text-5xl mb-3">🎬</div>
            <div>لا يوجد ريلز</div>
        </div>
    @endforelse
</div>

{{-- Pagination --}}
@if($reels->hasPages())
    <div class="mt-6">{{ $reels->links() }}</div>
@endif

@endsection
