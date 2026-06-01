@extends('layouts.admin')
@section('title', 'الأخصائيون')

@section('content')

{{-- Filter Tabs --}}
<div class="flex items-center gap-2 mb-5 bg-white rounded-2xl p-2 border border-gray-100 shadow-sm w-fit">
    @foreach(['all' => 'الكل', 'pending' => 'بانتظار الموافقة', 'approved' => 'موثق'] as $val => $label)
        <a href="{{ route('admin.therapists.index', ['status' => $val === 'all' ? null : $val]) }}"
           class="px-4 py-2 rounded-xl text-sm font-semibold transition-all
                  {{ (request('status', 'all') === $val) ? 'bg-[#1B5E7B] text-white shadow' : 'text-gray-600 hover:bg-gray-50' }}">
            {{ $label }}
        </a>
    @endforeach
</div>

{{-- Search + Table --}}
<div class="bg-white rounded-2xl border border-gray-100 shadow-sm">
    {{-- Search Bar --}}
    <div class="p-4 border-b border-gray-100">
        <form method="GET" action="{{ route('admin.therapists.index') }}" class="flex gap-3">
            @if(request('status'))
                <input type="hidden" name="status" value="{{ request('status') }}">
            @endif
            <input type="text" name="search" value="{{ request('search') }}"
                   placeholder="بحث بالاسم..."
                   class="flex-1 border border-gray-200 rounded-xl px-4 py-2 text-sm focus:outline-none focus:border-[#1B5E7B] focus:ring-2 focus:ring-[#1B5E7B]/20">
            <button class="bg-[#1B5E7B] text-white px-5 py-2 rounded-xl text-sm font-semibold hover:bg-[#154d66] transition-colors">
                بحث
            </button>
        </form>
    </div>

    {{-- Table --}}
    <div class="overflow-x-auto">
        <table class="w-full text-sm">
            <thead>
                <tr class="bg-gray-50 text-gray-500 text-xs font-semibold">
                    <th class="px-5 py-3 text-right">الأخصائي</th>
                    <th class="px-5 py-3 text-right">الهاتف</th>
                    <th class="px-5 py-3 text-right">التخصص</th>
                    <th class="px-5 py-3 text-right">المواعيد</th>
                    <th class="px-5 py-3 text-right">التقييم</th>
                    <th class="px-5 py-3 text-right">الحالة</th>
                    <th class="px-5 py-3 text-right">الإجراءات</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-50">
                @forelse($therapists as $therapist)
                    <tr class="hover:bg-gray-50/50 transition-colors">
                        <td class="px-5 py-4">
                            <div class="flex items-center gap-3">
                                @if($therapist->avatar)
                                    <img src="{{ $therapist->avatar }}" class="w-10 h-10 rounded-xl object-cover">
                                @else
                                    <div class="w-10 h-10 rounded-xl bg-[#1B5E7B]/10 flex items-center justify-center text-[#1B5E7B] font-bold">
                                        {{ mb_substr($therapist->full_name, 0, 1) }}
                                    </div>
                                @endif
                                <div>
                                    <div class="font-semibold text-gray-800">{{ $therapist->full_name }}</div>
                                    <div class="text-xs text-gray-400">{{ $therapist->title }}</div>
                                </div>
                            </div>
                        </td>
                        <td class="px-5 py-4 text-gray-500 font-mono text-xs">
                            {{ $therapist->user->phone_country_code }} {{ $therapist->user->phone }}
                        </td>
                        <td class="px-5 py-4">
                            <div class="flex flex-wrap gap-1">
                                @foreach($therapist->specializations->take(2) as $spec)
                                    <span class="text-xs bg-blue-50 text-blue-600 px-2 py-0.5 rounded-full">{{ $spec->name_ar }}</span>
                                @endforeach
                            </div>
                        </td>
                        <td class="px-5 py-4 font-semibold text-gray-700">{{ $therapist->appointments_count }}</td>
                        <td class="px-5 py-4">
                            <div class="flex items-center gap-1">
                                <span class="text-yellow-400">★</span>
                                <span class="font-semibold">{{ $therapist->rating_average }}</span>
                                <span class="text-xs text-gray-400">({{ $therapist->rating_count }})</span>
                            </div>
                        </td>
                        <td class="px-5 py-4">
                            @if($therapist->is_approved)
                                <span class="inline-flex items-center gap-1 bg-green-50 text-green-700 text-xs font-semibold px-3 py-1 rounded-full border border-green-100">
                                    ✓ موثق
                                </span>
                            @else
                                <span class="inline-flex items-center gap-1 bg-yellow-50 text-yellow-700 text-xs font-semibold px-3 py-1 rounded-full border border-yellow-100">
                                    ⏳ معلق
                                </span>
                            @endif
                        </td>
                        <td class="px-5 py-4">
                            <div class="flex gap-2">
                                <a href="{{ route('admin.therapists.show', $therapist) }}"
                                   class="text-xs bg-gray-100 hover:bg-gray-200 text-gray-700 px-3 py-1.5 rounded-lg transition-colors">
                                    عرض
                                </a>
                                <form method="POST" action="{{ route('admin.therapists.destroy', $therapist) }}"
                                      onsubmit="return confirm('حذف حساب {{ addslashes($therapist->full_name) }} نهائياً؟')">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit"
                                        class="text-xs bg-red-600 hover:bg-red-700 text-white px-3 py-1.5 rounded-lg transition-colors">
                                        حذف
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="7" class="text-center py-16 text-gray-400">
                            <div class="text-4xl mb-3">👨‍⚕️</div>
                            <div>لا يوجد أخصائيون</div>
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    {{-- Pagination --}}
    @if($therapists->hasPages())
        <div class="px-5 py-4 border-t border-gray-100">
            {{ $therapists->links() }}
        </div>
    @endif
</div>
@endsection
