@extends('layouts.admin')
@section('title', 'إعدادات التطبيق')

@section('content')

@if(session('success'))
<div class="mb-4 p-4 bg-green-50 border border-green-200 text-green-700 rounded-xl text-sm font-semibold">
    ✓ {{ session('success') }}
</div>
@endif
@if(session('error'))
<div class="mb-4 p-4 bg-red-50 border border-red-200 text-red-700 rounded-xl text-sm font-semibold">
    ✗ {{ session('error') }}
</div>
@endif

<div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

    {{-- Settings Form --}}
    <div class="lg:col-span-2 space-y-6">
        <form method="POST" action="{{ route('admin.settings.update') }}">
            @csrf
            @method('PUT')

            @foreach($settings as $group => $items)
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
                <h2 class="font-bold text-gray-800 mb-5 text-base flex items-center gap-2">
                    @if($group === 'support') 💬 دعم العملاء
                    @elseif($group === 'general') ⚙️ إعدادات عامة
                    @else {{ $group }}
                    @endif
                </h2>
                <div class="space-y-4">
                    @foreach($items as $setting)
                    <div>
                        <label class="block text-sm font-semibold text-gray-700 mb-1.5">
                            {{ $setting->label ?? $setting->key }}
                        </label>
                        @if($setting->type === 'boolean')
                            <label class="flex items-center gap-3 cursor-pointer">
                                <div class="relative">
                                    <input type="hidden" name="{{ $setting->key }}" value="0">
                                    <input type="checkbox" name="{{ $setting->key }}" value="1"
                                        {{ $setting->value == '1' ? 'checked' : '' }}
                                        class="sr-only peer">
                                    <div class="w-11 h-6 bg-gray-200 rounded-full peer-checked:bg-[#1B5E7B] transition-colors"></div>
                                    <div class="absolute top-0.5 left-0.5 w-5 h-5 bg-white rounded-full shadow transition-transform peer-checked:translate-x-5"></div>
                                </div>
                                <span class="text-sm text-gray-600">{{ $setting->value == '1' ? 'مفعّل' : 'معطّل' }}</span>
                            </label>
                        @elseif($setting->type === 'textarea')
                            <textarea name="{{ $setting->key }}" rows="3"
                                class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-[#1B5E7B]/30 focus:border-[#1B5E7B] resize-none">{{ $setting->value }}</textarea>
                        @else
                            <input type="text" name="{{ $setting->key }}" value="{{ $setting->value }}"
                                class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-[#1B5E7B]/30 focus:border-[#1B5E7B]"
                                @if($setting->key === 'whatsapp_support') placeholder="+970598XXXXXX" @endif>
                        @endif
                        @if($setting->key === 'whatsapp_support')
                            <p class="text-xs text-gray-400 mt-1">أدخل رقم الواتساب بالصيغة الدولية مثل: +970598123456</p>
                        @endif
                    </div>
                    @endforeach
                </div>
            </div>
            @endforeach

            <button type="submit"
                class="w-full bg-[#1B5E7B] hover:bg-[#0F4459] text-white font-bold py-3 rounded-xl transition-colors text-sm">
                💾 حفظ الإعدادات
            </button>
        </form>
    </div>

    {{-- Push Notification Panel --}}
    <div class="space-y-6">
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
            <h2 class="font-bold text-gray-800 mb-5 text-base">📢 إرسال إشعار جماعي</h2>
            <form method="POST" action="{{ route('admin.settings.push') }}">
                @csrf
                <div class="space-y-4">
                    <div>
                        <label class="block text-sm font-semibold text-gray-700 mb-1.5">المستهدفون</label>
                        <select name="role" class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-[#1B5E7B]/30">
                            <option value="all">الجميع</option>
                            <option value="patient">المرضى فقط</option>
                            <option value="therapist">الأخصائيون فقط</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-sm font-semibold text-gray-700 mb-1.5">عنوان الإشعار *</label>
                        <input type="text" name="title" required maxlength="100"
                            class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-[#1B5E7B]/30">
                    </div>
                    <div>
                        <label class="block text-sm font-semibold text-gray-700 mb-1.5">نص الإشعار *</label>
                        <textarea name="body" required maxlength="500" rows="3"
                            class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-[#1B5E7B]/30 resize-none"></textarea>
                    </div>
                    <button type="submit"
                        class="w-full bg-emerald-600 hover:bg-emerald-700 text-white font-bold py-3 rounded-xl transition-colors text-sm"
                        onclick="return confirm('هل تريد إرسال الإشعار لجميع المستخدمين المختارين؟')">
                        🚀 إرسال الإشعار
                    </button>
                </div>
            </form>
        </div>

        {{-- Quick Links --}}
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
            <h2 class="font-bold text-gray-800 mb-4 text-base">🔗 روابط سريعة</h2>
            <div class="space-y-2">
                <a href="{{ route('admin.pages.index') }}"
                   class="flex items-center justify-between p-3 bg-gray-50 hover:bg-gray-100 rounded-xl transition-colors text-sm">
                    <span class="font-semibold text-gray-700">📄 إدارة الصفحات</span>
                    <span class="text-[#1B5E7B]">→</span>
                </a>
                <a href="{{ route('admin.therapists.index') }}"
                   class="flex items-center justify-between p-3 bg-gray-50 hover:bg-gray-100 rounded-xl transition-colors text-sm">
                    <span class="font-semibold text-gray-700">👨‍⚕️ الأخصائيون</span>
                    <span class="text-[#1B5E7B]">→</span>
                </a>
                <a href="{{ route('admin.patients.index') }}"
                   class="flex items-center justify-between p-3 bg-gray-50 hover:bg-gray-100 rounded-xl transition-colors text-sm">
                    <span class="font-semibold text-gray-700">🧑‍🤝‍🧑 المرضى</span>
                    <span class="text-[#1B5E7B]">→</span>
                </a>
            </div>
        </div>
    </div>
</div>

@endsection
