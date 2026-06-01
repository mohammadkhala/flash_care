@extends('layouts.admin')
@section('title', 'المرضى')

@section('content')
<div class="bg-white rounded-2xl border border-gray-100 shadow-sm">

    {{-- Search --}}
    <div class="p-4 border-b border-gray-100 flex items-center justify-between gap-4">
        <form method="GET" action="{{ route('admin.patients.index') }}" class="flex gap-3 flex-1">
            <input type="text" name="search" value="{{ request('search') }}"
                   placeholder="بحث بالاسم أو رقم الهاتف..."
                   class="flex-1 border border-gray-200 rounded-xl px-4 py-2 text-sm outline-none transition-all"
                   onfocus="this.style.borderColor='#1B2E6E'" onblur="this.style.borderColor=''">
            <button class="text-white px-5 py-2 rounded-xl text-sm font-semibold transition-colors"
                    style="background:#1B2E6E">بحث</button>
        </form>
        <span class="text-sm text-gray-400">{{ $users->total() }} مريض</span>
    </div>

    {{-- Table --}}
    <div class="overflow-x-auto">
        <table class="w-full text-sm">
            <thead>
                <tr class="bg-gray-50 text-gray-500 text-xs font-semibold uppercase tracking-wide">
                    <th class="px-5 py-3 text-right">المريض</th>
                    <th class="px-5 py-3 text-right">الهاتف</th>
                    <th class="px-5 py-3 text-right">الجنس</th>
                    <th class="px-5 py-3 text-right">المواعيد</th>
                    <th class="px-5 py-3 text-right">تاريخ التسجيل</th>
                    <th class="px-5 py-3 text-right">الحالة</th>
                    <th class="px-5 py-3 text-right">إجراءات</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-50">
                @forelse($users as $user)
                    @php $patient = $user->patient; @endphp
                    <tr class="hover:bg-gray-50/50 transition-colors">

                        {{-- Name / Avatar --}}
                        <td class="px-5 py-4">
                            <div class="flex items-center gap-3">
                                <div class="w-9 h-9 rounded-xl flex items-center justify-center font-bold text-sm text-white flex-shrink-0"
                                     style="background: linear-gradient(135deg,#1B2E6E,#2D4A9E)">
                                    {{ $patient ? mb_substr($patient->full_name, 0, 1) : '?' }}
                                </div>
                                <div>
                                    <div class="font-semibold text-gray-800">
                                        {{ $patient?->full_name ?? '—' }}
                                    </div>
                                    @unless($patient)
                                        <span class="text-xs text-amber-500 font-medium">ملف غير مكتمل</span>
                                    @endunless
                                </div>
                            </div>
                        </td>

                        {{-- Phone --}}
                        <td class="px-5 py-4 text-gray-500 font-mono text-xs">
                            {{ $user->phone_country_code }} {{ $user->phone }}
                        </td>

                        {{-- Gender --}}
                        <td class="px-5 py-4 text-gray-600">
                            @if($patient?->gender === 'male') ذكر
                            @elseif($patient?->gender === 'female') أنثى
                            @else <span class="text-gray-300">—</span>
                            @endif
                        </td>

                        {{-- Appointments --}}
                        <td class="px-5 py-4 font-semibold text-center">
                            {{ $patient?->appointments_count ?? 0 }}
                        </td>

                        {{-- Created at --}}
                        <td class="px-5 py-4 text-gray-400 text-xs">
                            {{ $user->created_at->format('Y/m/d') }}
                        </td>

                        {{-- Status --}}
                        <td class="px-5 py-4">
                            <span class="text-xs font-semibold px-3 py-1 rounded-full
                                {{ $user->is_active ? 'bg-green-50 text-green-700' : 'bg-red-50 text-red-700' }}">
                                {{ $user->is_active ? 'نشط' : 'موقوف' }}
                            </span>
                        </td>

                        {{-- Actions --}}
                        <td class="px-5 py-4">
                            <div class="flex gap-2">
                                <a href="{{ route('admin.patients.show', $user) }}"
                                   class="text-xs bg-gray-100 hover:bg-gray-200 text-gray-700 px-3 py-1.5 rounded-lg transition-colors">
                                   عرض
                                </a>
                                <form method="POST" action="{{ route('admin.patients.active', $user) }}">
                                    @csrf
                                    <button class="text-xs px-3 py-1.5 rounded-lg transition-colors
                                        {{ $user->is_active
                                            ? 'bg-red-50 text-red-600 hover:bg-red-100'
                                            : 'bg-green-50 text-green-600 hover:bg-green-100' }}">
                                        {{ $user->is_active ? 'إيقاف' : 'تفعيل' }}
                                    </button>
                                </form>
                                <form method="POST" action="{{ route('admin.patients.destroy', $user) }}"
                                      onsubmit="return confirm('حذف هذا الحساب نهائياً؟')">
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
                            <div class="text-5xl mb-3">🧑‍🤝‍🧑</div>
                            <div class="font-medium">لا يوجد مرضى مسجلون بعد</div>
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    {{-- Pagination --}}
    @if($users->hasPages())
        <div class="px-5 py-4 border-t border-gray-100">{{ $users->links() }}</div>
    @endif
</div>
@endsection
