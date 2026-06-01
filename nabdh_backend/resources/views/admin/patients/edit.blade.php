@extends('layouts.admin')
@section('title', 'تعديل: ' . ($user->patient?->full_name ?? 'مريض'))

@section('content')

<div class="mb-5 flex items-center gap-3">
    <a href="{{ route('admin.patients.show', $user) }}"
       class="text-gray-400 hover:text-gray-700 transition-colors text-sm">← رجوع</a>
    <span class="text-gray-300">/</span>
    <h1 class="text-lg font-bold text-gray-800">تعديل بيانات المريض</h1>
</div>

@if(session('success'))
    <div class="mb-5 bg-green-50 border border-green-200 text-green-800 text-sm font-semibold px-4 py-3 rounded-xl">
        {{ session('success') }}
    </div>
@endif

@if($errors->any())
    <div class="mb-5 bg-red-50 border border-red-200 text-red-700 text-sm px-4 py-3 rounded-xl">
        <ul class="list-disc list-inside space-y-1">
            @foreach($errors->all() as $error)<li>{{ $error }}</li>@endforeach
        </ul>
    </div>
@endif

@php $patient = $user->patient; @endphp

<form method="POST" action="{{ route('admin.patients.update', $user) }}"
      enctype="multipart/form-data">
    @csrf @method('PUT')

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-5">

        {{-- Sidebar --}}
        <div class="space-y-5">

            {{-- Avatar --}}
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5 text-center">
                <div class="w-20 h-20 rounded-2xl flex items-center justify-center font-black text-3xl text-white mx-auto mb-4"
                     style="background:linear-gradient(135deg,#1B2E6E,#2D4A9E)">
                    {{ $patient ? mb_substr($patient->full_name, 0, 1) : '?' }}
                </div>
                <label class="cursor-pointer bg-gray-50 hover:bg-gray-100 border border-gray-200 text-gray-600 text-xs font-semibold px-4 py-2 rounded-xl transition-colors block">
                    📷 تغيير الصورة
                    <input type="file" name="avatar" accept="image/*" class="hidden">
                </label>
            </div>

            {{-- Contact --}}
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
                <h3 class="font-bold text-sm text-gray-700 mb-4">معلومات الاتصال</h3>
                <div class="space-y-3">
                    <div>
                        <label class="text-xs text-gray-500 font-semibold block mb-1">كود الدولة</label>
                        <input type="text" name="phone_country_code"
                               value="{{ old('phone_country_code', $user->phone_country_code) }}"
                               class="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:border-[#1B2E6E]">
                    </div>
                    <div>
                        <label class="text-xs text-gray-500 font-semibold block mb-1">رقم الهاتف</label>
                        <input type="text" name="phone"
                               value="{{ old('phone', $user->phone) }}"
                               class="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:border-[#1B2E6E]">
                    </div>
                </div>
            </div>

            {{-- Emergency Contact --}}
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
                <h3 class="font-bold text-sm text-gray-700 mb-4">جهة اتصال الطوارئ</h3>
                <div class="space-y-3">
                    <div>
                        <label class="text-xs text-gray-500 font-semibold block mb-1">الاسم</label>
                        <input type="text" name="emergency_contact_name"
                               value="{{ old('emergency_contact_name', $patient?->emergency_contact_name) }}"
                               class="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:border-[#1B2E6E]">
                    </div>
                    <div>
                        <label class="text-xs text-gray-500 font-semibold block mb-1">الهاتف</label>
                        <input type="text" name="emergency_contact_phone"
                               value="{{ old('emergency_contact_phone', $patient?->emergency_contact_phone) }}"
                               class="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:border-[#1B2E6E]">
                    </div>
                </div>
            </div>
        </div>

        {{-- Main Form --}}
        <div class="lg:col-span-2 space-y-5">

            {{-- Basic Info --}}
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
                <h3 class="font-bold text-sm text-gray-700 mb-4">المعلومات الأساسية</h3>
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div class="sm:col-span-2">
                        <label class="text-xs text-gray-500 font-semibold block mb-1">الاسم الكامل *</label>
                        <input type="text" name="full_name" required
                               value="{{ old('full_name', $patient?->full_name) }}"
                               class="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm focus:outline-none focus:border-[#1B2E6E] focus:ring-2 focus:ring-[#1B2E6E]/10">
                    </div>
                    <div>
                        <label class="text-xs text-gray-500 font-semibold block mb-1">الجنس</label>
                        <select name="gender" class="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm focus:outline-none focus:border-[#1B2E6E] bg-white">
                            <option value="">— اختر —</option>
                            <option value="male"   {{ old('gender', $patient?->gender) === 'male'   ? 'selected' : '' }}>ذكر</option>
                            <option value="female" {{ old('gender', $patient?->gender) === 'female' ? 'selected' : '' }}>أنثى</option>
                        </select>
                    </div>
                    <div>
                        <label class="text-xs text-gray-500 font-semibold block mb-1">تاريخ الميلاد</label>
                        <input type="date" name="date_of_birth"
                               value="{{ old('date_of_birth', $patient?->date_of_birth?->format('Y-m-d')) }}"
                               class="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm focus:outline-none focus:border-[#1B2E6E]">
                    </div>
                    <div class="sm:col-span-2">
                        <label class="text-xs text-gray-500 font-semibold block mb-1">المدينة</label>
                        <input type="text" name="city"
                               value="{{ old('city', $patient?->city) }}"
                               class="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm focus:outline-none focus:border-[#1B2E6E]">
                    </div>
                </div>
            </div>

            {{-- Medical Info --}}
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
                <h3 class="font-bold text-sm text-gray-700 mb-4">المعلومات الطبية</h3>
                <div class="space-y-4">
                    <div>
                        <label class="text-xs text-gray-500 font-semibold block mb-1">التاريخ الطبي</label>
                        <textarea name="medical_history" rows="4"
                                  placeholder="الحالات والأمراض السابقة..."
                                  class="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm focus:outline-none focus:border-[#1B2E6E] resize-none">{{ old('medical_history', $patient?->medical_history) }}</textarea>
                    </div>
                    <div>
                        <label class="text-xs text-gray-500 font-semibold block mb-1">الحساسية</label>
                        <textarea name="allergies" rows="3"
                                  placeholder="الحساسية من أدوية أو مواد..."
                                  class="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm focus:outline-none focus:border-[#1B2E6E] resize-none">{{ old('allergies', $patient?->allergies) }}</textarea>
                    </div>
                </div>
            </div>

            {{-- Actions --}}
            <div class="flex gap-3">
                <button type="submit"
                        class="font-bold px-8 py-3 rounded-xl transition-colors shadow-sm text-white"
                        style="background:#1B2E6E">
                    💾 حفظ التعديلات
                </button>
                <a href="{{ route('admin.patients.show', $user) }}"
                   class="bg-gray-100 hover:bg-gray-200 text-gray-700 font-bold px-6 py-3 rounded-xl transition-colors">
                    إلغاء
                </a>
            </div>
        </div>
    </div>
</form>
@endsection
