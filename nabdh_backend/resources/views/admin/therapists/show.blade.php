@extends('layouts.admin')
@section('title', $therapist->full_name)

@section('content')

<div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

    {{-- Profile Card --}}
    <div class="lg:col-span-1 space-y-5">

        {{-- Main Info --}}
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 text-center">
            @if($therapist->avatar)
                <img src="{{ \Illuminate\Support\Facades\Storage::disk('public')->url($therapist->avatar) }}" class="w-24 h-24 rounded-2xl mx-auto mb-4 object-cover">
            @else
                <div class="w-24 h-24 rounded-2xl bg-[#1B5E7B]/10 flex items-center justify-center text-[#1B5E7B] font-black text-3xl mx-auto mb-4">
                    {{ mb_substr($therapist->full_name, 0, 1) }}
                </div>
            @endif
            <h2 class="font-bold text-xl text-gray-800">{{ $therapist->full_name }}</h2>
            @if($therapist->title)
                <p class="text-gray-500 text-sm mt-1">{{ $therapist->title }}</p>
            @endif
            <div class="mt-3">
                @if($therapist->is_approved)
                    <span class="bg-green-50 text-green-700 text-xs font-semibold px-4 py-1.5 rounded-full border border-green-100">✓ موثق</span>
                @else
                    <span class="bg-yellow-50 text-yellow-700 text-xs font-semibold px-4 py-1.5 rounded-full border border-yellow-100">⏳ بانتظار الموافقة</span>
                @endif
                @if($therapist->is_featured)
                    <span class="bg-purple-50 text-purple-700 text-xs font-semibold px-4 py-1.5 rounded-full border border-purple-100 mr-1">⭐ مميز</span>
                @endif
            </div>
        </div>

        {{-- Stats --}}
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
            <h3 class="font-bold text-sm text-gray-700 mb-4">الإحصائيات</h3>
            <div class="space-y-3">
                <div class="flex justify-between"><span class="text-gray-500 text-sm">الهاتف</span><span class="font-semibold text-sm">{{ $therapist->user->phone_country_code }} {{ $therapist->user->phone }}</span></div>
                <div class="flex justify-between"><span class="text-gray-500 text-sm">التقييم</span><span class="font-semibold text-sm">⭐ {{ $therapist->rating_average }} ({{ $therapist->rating_count }})</span></div>
                <div class="flex justify-between"><span class="text-gray-500 text-sm">سنوات الخبرة</span><span class="font-semibold text-sm">{{ $therapist->years_experience }}</span></div>
                <div class="flex justify-between"><span class="text-gray-500 text-sm">المدينة</span><span class="font-semibold text-sm">{{ $therapist->city ?? '-' }}</span></div>
                <div class="flex justify-between"><span class="text-gray-500 text-sm">إجمالي المواعيد</span><span class="font-semibold text-sm">{{ $therapist->appointments->count() }}</span></div>
                <div class="flex justify-between"><span class="text-gray-500 text-sm">تاريخ التسجيل</span><span class="font-semibold text-sm">{{ $therapist->created_at->format('Y/m/d') }}</span></div>
            </div>
        </div>

        {{-- Documents --}}
        @if($therapist->documents->isNotEmpty())
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
                <h3 class="font-bold text-sm text-gray-700 mb-4">الوثائق</h3>
                <div class="space-y-2">
                    @foreach($therapist->documents as $doc)
                        <a href="{{ Storage::url($doc->file_path) }}" target="_blank"
                           class="flex items-center justify-between p-3 bg-gray-50 rounded-xl hover:bg-gray-100 transition-colors">
                            <span class="text-xs font-semibold text-gray-600">{{ $doc->type === 'license' ? 'رخصة' : ($doc->type === 'id_card' ? 'هوية' : 'شهادة') }}</span>
                            <span class="text-xs text-[#1B5E7B]">عرض ↗</span>
                        </a>
                    @endforeach
                </div>
            </div>
        @endif
    </div>

    {{-- Main Content --}}
    <div class="lg:col-span-2 space-y-5">

        {{-- Approval Actions --}}
        @if(!$therapist->is_approved)
            <div class="bg-amber-50 border border-amber-200 rounded-2xl p-5" x-data="{ rejectOpen: false }">
                <h3 class="font-bold text-amber-800 mb-3">الإجراءات المطلوبة</h3>
                <p class="text-amber-700 text-sm mb-4">يرجى مراجعة بيانات الأخصائي ووثائقه قبل اتخاذ القرار.</p>
                <div class="flex gap-3">
                    <form method="POST" action="{{ route('admin.therapists.approve', $therapist) }}">
                        @csrf
                        <button class="bg-green-600 hover:bg-green-700 text-white font-bold px-6 py-2.5 rounded-xl transition-colors text-sm">
                            ✓ قبول وتوثيق
                        </button>
                    </form>
                    <button @click="rejectOpen = !rejectOpen"
                            class="bg-red-100 hover:bg-red-200 text-red-700 font-bold px-6 py-2.5 rounded-xl transition-colors text-sm">
                        ✕ رفض
                    </button>
                </div>
                <div x-show="rejectOpen" x-transition class="mt-4">
                    <form method="POST" action="{{ route('admin.therapists.reject', $therapist) }}" class="space-y-3">
                        @csrf
                        <textarea name="reason" rows="3" required
                                  placeholder="سبب الرفض (سيصل للأخصائي)..."
                                  class="w-full border border-red-200 rounded-xl px-4 py-3 text-sm focus:outline-none focus:border-red-400"></textarea>
                        <button class="bg-red-600 hover:bg-red-700 text-white font-bold px-6 py-2.5 rounded-xl transition-colors text-sm">
                            إرسال الرفض
                        </button>
                    </form>
                </div>
            </div>
        @endif

        {{-- Bio --}}
        @if($therapist->bio)
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
                <h3 class="font-bold text-sm text-gray-700 mb-3">النبذة التعريفية</h3>
                <p class="text-gray-600 text-sm leading-relaxed">{{ $therapist->bio }}</p>
            </div>
        @endif

        {{-- Specializations --}}
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
            <h3 class="font-bold text-sm text-gray-700 mb-3">التخصصات</h3>
            <div class="flex flex-wrap gap-2">
                @forelse($therapist->specializations as $spec)
                    <span class="bg-blue-50 text-blue-700 text-sm px-4 py-1.5 rounded-full border border-blue-100 font-semibold">{{ $spec->name_ar }}</span>
                @empty
                    <span class="text-gray-400 text-sm">لا يوجد تخصصات مضافة</span>
                @endforelse
            </div>
        </div>

        {{-- Recent Appointments --}}
        @if($therapist->appointments->isNotEmpty())
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm">
                <div class="p-5 border-b border-gray-100">
                    <h3 class="font-bold text-sm text-gray-700">آخر المواعيد</h3>
                </div>
                <div class="divide-y divide-gray-50">
                    @foreach($therapist->appointments->take(5) as $appt)
                        <div class="px-5 py-3 flex items-center justify-between">
                            <div>
                                <div class="text-sm font-semibold">{{ $appt->patient->full_name ?? 'مريض محذوف' }}</div>
                                <div class="text-xs text-gray-400">{{ $appt->scheduled_at->format('Y/m/d H:i') }}</div>
                            </div>
                            <span @class([
                                'text-xs font-semibold px-3 py-1 rounded-full',
                                'bg-green-50 text-green-700' => $appt->status === 'completed',
                                'bg-blue-50 text-blue-700' => $appt->status === 'confirmed',
                                'bg-yellow-50 text-yellow-700' => $appt->status === 'pending',
                                'bg-red-50 text-red-700' => str_contains($appt->status, 'cancelled'),
                            ])>
                                {{ match($appt->status) {
                                    'completed' => 'مكتمل',
                                    'confirmed' => 'مؤكد',
                                    'pending'   => 'معلق',
                                    default     => 'ملغي',
                                } }}
                            </span>
                        </div>
                    @endforeach
                </div>
            </div>
        @endif

        {{-- Control Actions --}}
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
            <h3 class="font-bold text-sm text-gray-700 mb-4">الإجراءات</h3>
            <div class="flex flex-wrap gap-3">
                <form method="POST" action="{{ route('admin.therapists.featured', $therapist) }}">
                    @csrf
                    <button class="bg-purple-50 hover:bg-purple-100 text-purple-700 font-semibold px-4 py-2 rounded-xl text-sm transition-colors border border-purple-100">
                        {{ $therapist->is_featured ? '⭐ إلغاء التمييز' : '⭐ تمييز الأخصائي' }}
                    </button>
                </form>
                <form method="POST" action="{{ route('admin.therapists.active', $therapist) }}">
                    @csrf
                    <button class="bg-gray-50 hover:bg-gray-100 text-gray-700 font-semibold px-4 py-2 rounded-xl text-sm transition-colors border border-gray-200">
                        {{ $therapist->user->is_active ? '🔒 إيقاف الحساب' : '🔓 تفعيل الحساب' }}
                    </button>
                </form>
                <form method="POST" action="{{ route('admin.therapists.destroy', $therapist) }}"
                      onsubmit="return confirm('⚠️ هل أنت متأكد من حذف حساب {{ addslashes($therapist->full_name) }} نهائياً؟\nستُحذف جميع بياناته ومواعيده ولا يمكن التراجع.')">
                    @csrf
                    @method('DELETE')
                    <button type="submit"
                        class="bg-red-600 hover:bg-red-700 text-white font-semibold px-4 py-2 rounded-xl text-sm transition-colors">
                        🗑️ حذف الحساب نهائياً
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection
