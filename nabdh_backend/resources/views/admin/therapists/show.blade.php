@extends('layouts.admin')
@section('title', $therapist->full_name)

@section('content')

@if(session('success'))
    <div class="mb-5 bg-green-50 border border-green-200 text-green-800 text-sm font-semibold px-4 py-3 rounded-xl">
        {{ session('success') }}
    </div>
@endif

<div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

    {{-- ─── Sidebar ──────────────────────────────────────────────────────── --}}
    <div class="lg:col-span-1 space-y-5">

        {{-- Main Info --}}
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 text-center">
            @if($therapist->avatar)
                <img src="{{ \Illuminate\Support\Facades\Storage::disk('public')->url($therapist->avatar) }}"
                     class="w-24 h-24 rounded-2xl mx-auto mb-4 object-cover">
            @else
                <div class="w-24 h-24 rounded-2xl bg-[#1B5E7B]/10 flex items-center justify-center text-[#1B5E7B] font-black text-3xl mx-auto mb-4">
                    {{ mb_substr($therapist->full_name, 0, 1) }}
                </div>
            @endif
            <h2 class="font-bold text-xl text-gray-800">{{ $therapist->full_name }}</h2>
            @if($therapist->title)
                <p class="text-gray-500 text-sm mt-1">{{ $therapist->title }}</p>
            @endif
            <div class="mt-3 flex flex-wrap justify-center gap-2">
                @if($therapist->is_approved)
                    <span class="bg-green-50 text-green-700 text-xs font-semibold px-3 py-1 rounded-full border border-green-100">✓ موثق</span>
                @else
                    <span class="bg-yellow-50 text-yellow-700 text-xs font-semibold px-3 py-1 rounded-full border border-yellow-100">⏳ بانتظار الموافقة</span>
                @endif
                @if($therapist->is_featured)
                    <span class="bg-purple-50 text-purple-700 text-xs font-semibold px-3 py-1 rounded-full border border-purple-100">⭐ مميز</span>
                @endif
                <span class="{{ $therapist->user->is_active ? 'bg-green-50 text-green-700 border-green-100' : 'bg-red-50 text-red-700 border-red-100' }} text-xs font-semibold px-3 py-1 rounded-full border">
                    {{ $therapist->user->is_active ? '🟢 نشط' : '🔴 موقوف' }}
                </span>
            </div>
        </div>

        {{-- Stats --}}
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
            <h3 class="font-bold text-sm text-gray-700 mb-4">الإحصائيات</h3>
            <div class="space-y-3 text-sm">
                <div class="flex justify-between"><span class="text-gray-500">الهاتف</span><span class="font-semibold">{{ $therapist->user->phone_country_code }} {{ $therapist->user->phone }}</span></div>
                <div class="flex justify-between"><span class="text-gray-500">التقييم</span><span class="font-semibold">⭐ {{ $therapist->rating_average }} ({{ $therapist->rating_count }})</span></div>
                <div class="flex justify-between"><span class="text-gray-500">سنوات الخبرة</span><span class="font-semibold">{{ $therapist->years_experience ?? '—' }}</span></div>
                <div class="flex justify-between"><span class="text-gray-500">المدينة</span><span class="font-semibold">{{ $therapist->city ?? '—' }}</span></div>
                <div class="flex justify-between"><span class="text-gray-500">المواعيد</span><span class="font-semibold">{{ $therapist->appointments->count() }}</span></div>
                <div class="flex justify-between"><span class="text-gray-500">الريلز</span><span class="font-semibold">{{ $therapist->reels->count() }}</span></div>
                <div class="flex justify-between"><span class="text-gray-500">تسعير الأونلاين</span><span class="font-semibold">{{ $therapist->online_session_price ? '₪'.$therapist->online_session_price : '—' }}</span></div>
                <div class="flex justify-between"><span class="text-gray-500">تسعير الحضوري</span><span class="font-semibold">{{ $therapist->in_person_session_price ? '₪'.$therapist->in_person_session_price : '—' }}</span></div>
                <div class="flex justify-between"><span class="text-gray-500">مدة الجلسة</span><span class="font-semibold">{{ $therapist->session_duration ? $therapist->session_duration.' د' : '—' }}</span></div>
                <div class="flex justify-between"><span class="text-gray-500">تاريخ التسجيل</span><span class="font-semibold">{{ $therapist->created_at->format('Y/m/d') }}</span></div>
            </div>
        </div>

        {{-- Documents --}}
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
            <div class="flex items-center justify-between mb-4">
                <h3 class="font-bold text-sm text-gray-700">الوثائق المرفوعة</h3>
                <span class="text-xs font-semibold px-2.5 py-1 rounded-full
                    {{ $therapist->documents->isNotEmpty() ? 'bg-blue-50 text-blue-700' : 'bg-red-50 text-red-600' }}">
                    {{ $therapist->documents->count() }} وثيقة
                </span>
            </div>
            @if($therapist->documents->isNotEmpty())
                <div class="space-y-2">
                    @foreach($therapist->documents as $doc)
                        @php
                            $icon = match($doc->type) {
                                'cv'          => '📋',
                                'license'     => '📄',
                                'certificate' => '🎓',
                                default       => '📁',
                            };
                            $typeLabel = match($doc->type) {
                                'cv'          => 'السيرة الذاتية',
                                'license'     => 'الترخيص المهني',
                                'certificate' => 'شهادة / دبلوم',
                                default       => 'وثيقة أخرى',
                            };
                        @endphp
                        <a href="{{ Storage::url($doc->file_path) }}" target="_blank"
                           class="flex items-center gap-3 p-3 bg-gray-50 rounded-xl hover:bg-[#1B5E7B]/5 transition-colors group">
                            <span class="text-2xl leading-none">{{ $icon }}</span>
                            <div class="flex-1 min-w-0">
                                <div class="text-sm font-semibold text-gray-800 truncate">
                                    {{ $doc->label ?: $typeLabel }}
                                </div>
                                <div class="text-xs text-gray-400 truncate mt-0.5">
                                    {{ $doc->file_name ?? basename($doc->file_path) }}
                                    @if($doc->file_size)
                                        · {{ $doc->file_size }}
                                    @endif
                                </div>
                            </div>
                            <span class="text-xs text-[#1B5E7B] font-semibold opacity-0 group-hover:opacity-100 transition-opacity shrink-0">
                                فتح ↗
                            </span>
                        </a>
                    @endforeach
                </div>
            @else
                <div class="text-center py-6">
                    <div class="text-4xl mb-2">📭</div>
                    <p class="text-sm text-red-500 font-semibold">لم يرفع الأخصائي أي وثائق بعد</p>
                    <p class="text-xs text-gray-400 mt-1">يُنصح بالتواصل معه قبل القبول</p>
                </div>
            @endif
        </div>
    </div>

    {{-- ─── Main Content ──────────────────────────────────────────────────── --}}
    <div class="lg:col-span-2 space-y-5">

        {{-- Quick Actions --}}
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
            <h3 class="font-bold text-sm text-gray-700 mb-4">الإجراءات السريعة</h3>
            <div class="flex flex-wrap gap-2">
                {{-- Edit --}}
                <a href="{{ route('admin.therapists.edit', $therapist) }}"
                   class="bg-[#1B5E7B] hover:bg-[#154d66] text-white font-semibold px-4 py-2 rounded-xl text-sm transition-colors">
                    ✏️ تعديل البيانات
                </a>
                {{-- Featured --}}
                <form method="POST" action="{{ route('admin.therapists.featured', $therapist) }}">
                    @csrf
                    <button class="bg-purple-50 hover:bg-purple-100 text-purple-700 font-semibold px-4 py-2 rounded-xl text-sm transition-colors border border-purple-100">
                        {{ $therapist->is_featured ? '⭐ إلغاء التمييز' : '⭐ تمييز' }}
                    </button>
                </form>
                {{-- Toggle Active --}}
                <form method="POST" action="{{ route('admin.therapists.active', $therapist) }}">
                    @csrf
                    <button class="{{ $therapist->user->is_active ? 'bg-orange-50 text-orange-700 border-orange-100' : 'bg-green-50 text-green-700 border-green-100' }} font-semibold px-4 py-2 rounded-xl text-sm transition-colors border">
                        {{ $therapist->user->is_active ? '🔒 إيقاف الحساب' : '🔓 تفعيل الحساب' }}
                    </button>
                </form>
                {{-- Delete --}}
                <form method="POST" action="{{ route('admin.therapists.destroy', $therapist) }}"
                      onsubmit="return confirm('⚠️ هل أنت متأكد من حذف حساب {{ addslashes($therapist->full_name) }} نهائياً؟')">
                    @csrf @method('DELETE')
                    <button type="submit" class="bg-red-600 hover:bg-red-700 text-white font-semibold px-4 py-2 rounded-xl text-sm transition-colors">
                        🗑️ حذف نهائي
                    </button>
                </form>
            </div>
        </div>

        {{-- Approval Actions --}}
        @if(!$therapist->is_approved)
            <div class="bg-amber-50 border border-amber-200 rounded-2xl p-5" x-data="{ rejectOpen: false }">
                <h3 class="font-bold text-amber-800 mb-3">⚠️ الإجراءات المطلوبة</h3>
                <div class="text-amber-700 text-sm mb-4 space-y-1">
                    <p>يرجى مراجعة بيانات الأخصائي ووثائقه قبل اتخاذ القرار.</p>
                    @if($therapist->documents->isEmpty())
                        <p class="font-bold text-red-600">⛔ لم يرفع الأخصائي أي وثائق — السيرة الذاتية والترخيص مطلوبان للقبول.</p>
                    @elseif(!$therapist->documents->contains('type', 'cv'))
                        <p class="font-bold text-orange-600">⚠️ السيرة الذاتية (CV) غير مرفوعة بعد.</p>
                    @else
                        <p class="text-green-700">✅ رفع الأخصائي {{ $therapist->documents->count() }} وثيقة — راجعها في الشريط الجانبي.</p>
                    @endif
                </div>
                <div class="flex gap-3">
                    <form method="POST" action="{{ route('admin.therapists.approve', $therapist) }}">
                        @csrf
                        <button class="bg-green-600 hover:bg-green-700 text-white font-bold px-6 py-2.5 rounded-xl text-sm">✓ قبول وتوثيق</button>
                    </form>
                    <button @click="rejectOpen = !rejectOpen"
                            class="bg-red-100 hover:bg-red-200 text-red-700 font-bold px-6 py-2.5 rounded-xl text-sm">✕ رفض</button>
                </div>
                <div x-show="rejectOpen" x-transition class="mt-4">
                    <form method="POST" action="{{ route('admin.therapists.reject', $therapist) }}" class="space-y-3">
                        @csrf
                        <textarea name="reason" rows="3" required placeholder="سبب الرفض (سيصل للأخصائي)..."
                                  class="w-full border border-red-200 rounded-xl px-4 py-3 text-sm focus:outline-none"></textarea>
                        <button class="bg-red-600 hover:bg-red-700 text-white font-bold px-6 py-2.5 rounded-xl text-sm">إرسال الرفض</button>
                    </form>
                </div>
            </div>
        @endif

        {{-- Send Notification --}}
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5" x-data="{ open: false }">
            <div class="flex items-center justify-between cursor-pointer" @click="open = !open">
                <h3 class="font-bold text-sm text-gray-700">📣 إرسال إشعار للأخصائي</h3>
                <span class="text-gray-400 text-sm" x-text="open ? '▲' : '▼'"></span>
            </div>
            <div x-show="open" x-transition class="mt-4">
                <form method="POST" action="{{ route('admin.therapists.notify', $therapist) }}" class="space-y-3">
                    @csrf
                    <input type="text" name="title" required placeholder="عنوان الإشعار"
                           class="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm focus:outline-none focus:border-[#1B5E7B]">
                    <textarea name="body" rows="3" required placeholder="نص الإشعار..."
                              class="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm focus:outline-none focus:border-[#1B5E7B] resize-none"></textarea>
                    <button class="bg-[#1B5E7B] hover:bg-[#154d66] text-white font-bold px-5 py-2 rounded-xl text-sm transition-colors">
                        📤 إرسال الإشعار
                    </button>
                </form>
            </div>
        </div>

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
                    <span class="text-gray-400 text-sm">لا توجد تخصصات مضافة</span>
                @endforelse
            </div>
        </div>

        {{-- Recent Appointments --}}
        @if($therapist->appointments->isNotEmpty())
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm">
                <div class="p-5 border-b border-gray-100 flex items-center justify-between">
                    <h3 class="font-bold text-sm text-gray-700">آخر المواعيد</h3>
                    <a href="{{ route('admin.appointments.index') }}?search={{ $therapist->full_name }}"
                       class="text-xs text-[#1B5E7B] hover:underline">عرض الكل</a>
                </div>
                <div class="divide-y divide-gray-50">
                    @foreach($therapist->appointments->take(5) as $appt)
                        <a href="{{ route('admin.appointments.show', $appt) }}"
                           class="px-5 py-3 flex items-center justify-between hover:bg-gray-50 transition-colors block">
                            <div>
                                <div class="text-sm font-semibold">{{ $appt->patient->full_name ?? 'مريض محذوف' }}</div>
                                <div class="text-xs text-gray-400">{{ $appt->scheduled_at->format('Y/m/d H:i') }}</div>
                            </div>
                            <span @class([
                                'text-xs font-semibold px-3 py-1 rounded-full',
                                'bg-green-50 text-green-700'  => $appt->status === 'completed',
                                'bg-blue-50 text-blue-700'    => $appt->status === 'confirmed',
                                'bg-yellow-50 text-yellow-700'=> $appt->status === 'pending',
                                'bg-red-50 text-red-700'      => str_contains($appt->status, 'cancelled'),
                            ])>
                                {{ match($appt->status) {
                                    'completed' => 'مكتمل','confirmed' => 'مؤكد',
                                    'pending' => 'معلق', default => 'ملغي',
                                } }}
                            </span>
                        </a>
                    @endforeach
                </div>
            </div>
        @endif

        {{-- Home Programs --}}
        @if($therapist->homePrograms->isNotEmpty())
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm">
                <div class="p-5 border-b border-gray-100">
                    <h3 class="font-bold text-sm text-gray-700">البرامج المنزلية</h3>
                </div>
                <div class="divide-y divide-gray-50">
                    @foreach($therapist->homePrograms as $prog)
                        <div class="px-5 py-3 flex items-center justify-between">
                            <div class="text-sm font-semibold">{{ $prog->title }}</div>
                            <span class="text-xs text-gray-400">{{ $prog->created_at->format('Y/m/d') }}</span>
                        </div>
                    @endforeach
                </div>
            </div>
        @endif

        {{-- Reels --}}
        @if($therapist->reels->isNotEmpty())
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
                <h3 class="font-bold text-sm text-gray-700 mb-4">الريلز ({{ $therapist->reels->count() }})</h3>
                <div class="grid grid-cols-3 gap-2">
                    @foreach($therapist->reels->take(6) as $reel)
                        <div class="aspect-video bg-gray-100 rounded-xl overflow-hidden relative">
                            @if($reel->thumbnail)
                                <img src="{{ Storage::url($reel->thumbnail) }}" class="w-full h-full object-cover">
                            @else
                                <div class="w-full h-full flex items-center justify-center text-gray-400 text-2xl">🎬</div>
                            @endif
                            <div class="absolute bottom-1 left-1 text-[10px] px-1.5 py-0.5 rounded-full font-semibold
                                {{ $reel->status === 'approved' ? 'bg-green-500 text-white' : ($reel->status === 'pending' ? 'bg-yellow-400 text-white' : 'bg-red-500 text-white') }}">
                                {{ $reel->status === 'approved' ? '✓' : ($reel->status === 'pending' ? '⏳' : '✕') }}
                            </div>
                        </div>
                    @endforeach
                </div>
            </div>
        @endif

    </div>
</div>
@endsection
