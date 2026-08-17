@extends('layouts.admin')
@section('title', 'تعديل: ' . $therapist->full_name)

@section('content')

<div class="mb-5 flex items-center gap-3">
    <a href="{{ route('admin.therapists.show', $therapist) }}"
       class="text-gray-400 hover:text-gray-700 transition-colors text-sm flex items-center gap-1">
        ← رجوع
    </a>
    <span class="text-gray-300">/</span>
    <h1 class="text-lg font-bold text-gray-800">تعديل بيانات الأخصائي</h1>
</div>

@if(session('success'))
    <div class="mb-5 bg-green-50 border border-green-200 text-green-800 text-sm font-semibold px-4 py-3 rounded-xl">
        {{ session('success') }}
    </div>
@endif

@if($errors->any())
    <div class="mb-5 bg-red-50 border border-red-200 text-red-700 text-sm px-4 py-3 rounded-xl">
        <ul class="list-disc list-inside space-y-1">
            @foreach($errors->all() as $error)
                <li>{{ $error }}</li>
            @endforeach
        </ul>
    </div>
@endif

<form method="POST" action="{{ route('admin.therapists.update', $therapist) }}"
      enctype="multipart/form-data" class="space-y-5">
    @csrf
    @method('PUT')

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-5">

        {{-- ─── Left: Avatar + Quick Info ──────────────────────────── --}}
        <div class="space-y-5">

            {{-- Avatar --}}
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
                <h3 class="font-bold text-sm text-gray-700 mb-4">الصورة الشخصية</h3>
                <div class="flex flex-col items-center gap-4">
                    @if($therapist->avatar)
                        <img src="{{ Storage::url($therapist->avatar) }}"
                             class="w-24 h-24 rounded-2xl object-cover border border-gray-200">
                    @else
                        <div class="w-24 h-24 rounded-2xl bg-[#1B5E7B]/10 flex items-center justify-center text-[#1B5E7B] text-3xl font-black">
                            {{ mb_substr($therapist->full_name, 0, 1) }}
                        </div>
                    @endif
                    <label class="cursor-pointer bg-gray-50 hover:bg-gray-100 border border-gray-200 text-gray-600 text-xs font-semibold px-4 py-2 rounded-xl transition-colors w-full text-center">
                        📷 تغيير الصورة
                        <input type="file" name="avatar" accept="image/*" class="hidden">
                    </label>
                </div>
            </div>

            {{-- Contact --}}
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
                <h3 class="font-bold text-sm text-gray-700 mb-4">معلومات التواصل</h3>
                <div class="space-y-3">
                    <div>
                        <label class="text-xs text-gray-500 font-semibold block mb-1">كود الدولة</label>
                        <input type="text" name="phone_country_code"
                               value="{{ old('phone_country_code', $therapist->user->phone_country_code) }}"
                               class="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:border-[#1B5E7B]">
                    </div>
                    <div>
                        <label class="text-xs text-gray-500 font-semibold block mb-1">رقم الهاتف</label>
                        <input type="text" name="phone"
                               value="{{ old('phone', $therapist->user->phone) }}"
                               class="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:border-[#1B5E7B]">
                    </div>
                </div>
            </div>

            {{-- Session Settings --}}
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
                <h3 class="font-bold text-sm text-gray-700 mb-4">إعدادات الجلسة</h3>
                <div class="space-y-3">
                    <label class="flex items-center justify-between cursor-pointer">
                        <span class="text-sm text-gray-700">يقبل جلسات أونلاين</span>
                        <input type="checkbox" name="accepts_online" value="1"
                               {{ old('accepts_online', $therapist->accepts_online) ? 'checked' : '' }}
                               class="w-4 h-4 accent-[#1B5E7B]">
                    </label>
                    <div>
                        <label class="text-xs text-gray-500 font-semibold block mb-1">سعر الأونلاين (₪)</label>
                        <input type="number" name="online_session_price" min="0"
                               value="{{ old('online_session_price', $therapist->online_session_price) }}"
                               class="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:border-[#1B5E7B]">
                    </div>
                    <label class="flex items-center justify-between cursor-pointer">
                        <span class="text-sm text-gray-700">يقبل جلسات حضورية</span>
                        <input type="checkbox" name="accepts_in_person" value="1"
                               {{ old('accepts_in_person', $therapist->accepts_in_person) ? 'checked' : '' }}
                               class="w-4 h-4 accent-[#1B5E7B]">
                    </label>
                    <div>
                        <label class="text-xs text-gray-500 font-semibold block mb-1">سعر الحضوري (₪)</label>
                        <input type="number" name="in_person_session_price" min="0"
                               value="{{ old('in_person_session_price', $therapist->in_person_session_price) }}"
                               class="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:border-[#1B5E7B]">
                    </div>
                    <div>
                        <label class="text-xs text-gray-500 font-semibold block mb-1">مدة الجلسة (دقيقة)</label>
                        <input type="number" name="session_duration" min="15" max="180"
                               value="{{ old('session_duration', $therapist->session_duration) }}"
                               class="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:border-[#1B5E7B]">
                    </div>
                </div>
            </div>
        </div>

        {{-- ─── Right: Main Form ─────────────────────────────────────── --}}
        <div class="lg:col-span-2 space-y-5">

            {{-- Basic Info --}}
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
                <h3 class="font-bold text-sm text-gray-700 mb-4">المعلومات الأساسية</h3>
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                        <label class="text-xs text-gray-500 font-semibold block mb-1">الاسم (عربي) *</label>
                        <input type="text" name="full_name" required
                               value="{{ old('full_name', $therapist->full_name) }}"
                               class="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm focus:outline-none focus:border-[#1B5E7B] focus:ring-2 focus:ring-[#1B5E7B]/10">
                    </div>
                    <div>
                        <label class="text-xs text-gray-500 font-semibold block mb-1">الاسم (إنجليزي)</label>
                        <input type="text" name="full_name_en"
                               value="{{ old('full_name_en', $therapist->full_name_en) }}"
                               class="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm focus:outline-none focus:border-[#1B5E7B]">
                    </div>
                    <div>
                        <label class="text-xs text-gray-500 font-semibold block mb-1">اللقب / التخصص العام</label>
                        <input type="text" name="title"
                               value="{{ old('title', $therapist->title) }}"
                               placeholder="مثال: أخصائي نفسي معتمد"
                               class="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm focus:outline-none focus:border-[#1B5E7B]">
                    </div>
                    <div>
                        <label class="text-xs text-gray-500 font-semibold block mb-1">الدرجة العلمية</label>
                        <input type="text" name="degree"
                               value="{{ old('degree', $therapist->degree) }}"
                               placeholder="مثال: ماجستير علم النفس"
                               class="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm focus:outline-none focus:border-[#1B5E7B]">
                    </div>
                    <div>
                        <label class="text-xs text-gray-500 font-semibold block mb-1">الجنس</label>
                        <select name="gender" class="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm focus:outline-none focus:border-[#1B5E7B] bg-white">
                            <option value="">— اختر —</option>
                            <option value="male"   {{ old('gender', $therapist->gender) === 'male'   ? 'selected' : '' }}>ذكر</option>
                            <option value="female" {{ old('gender', $therapist->gender) === 'female' ? 'selected' : '' }}>أنثى</option>
                        </select>
                    </div>
                    <div>
                        <label class="text-xs text-gray-500 font-semibold block mb-1">المدينة</label>
                        <input type="text" name="city"
                               value="{{ old('city', $therapist->city) }}"
                               class="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm focus:outline-none focus:border-[#1B5E7B]">
                    </div>
                    <div class="sm:col-span-2">
                        <label class="text-xs text-gray-500 font-semibold block mb-1">سنوات الخبرة</label>
                        <input type="number" name="years_experience" min="0" max="60"
                               value="{{ old('years_experience', $therapist->years_experience) }}"
                               class="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm focus:outline-none focus:border-[#1B5E7B]">
                    </div>
                </div>
            </div>

            {{-- Location on map --}}
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
                <div class="flex items-center justify-between mb-1">
                    <h3 class="font-bold text-sm text-gray-700">الموقع على الخريطة</h3>
                    @if($therapist->latitude && $therapist->longitude)
                        <span class="text-xs font-semibold px-2.5 py-1 rounded-full bg-green-50 text-green-700">📍 محدَّد بدقة</span>
                    @else
                        <span class="text-xs font-semibold px-2.5 py-1 rounded-full bg-amber-50 text-amber-700">تقريبي حسب المدينة</span>
                    @endif
                </div>
                <p class="text-xs text-gray-400 mb-3">
                    اضغط على الخريطة أو اسحب الدبوس لتحديد موقع الأخصائي بدقة. إذا تُرك فارغاً،
                    يظهر الأخصائي في مركز مدينته على خريطة تطبيق المريض.
                </p>

                <div id="adminPickMap" class="w-full h-72 rounded-xl border border-gray-200 mb-3"></div>

                <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
                    <div>
                        <label class="text-xs text-gray-500 font-semibold block mb-1">خط العرض (Latitude)</label>
                        <input type="text" name="latitude" id="latInput"
                               value="{{ old('latitude', $therapist->latitude) }}"
                               class="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm focus:outline-none focus:border-[#1B5E7B]">
                    </div>
                    <div>
                        <label class="text-xs text-gray-500 font-semibold block mb-1">خط الطول (Longitude)</label>
                        <input type="text" name="longitude" id="lngInput"
                               value="{{ old('longitude', $therapist->longitude) }}"
                               class="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm focus:outline-none focus:border-[#1B5E7B]">
                    </div>
                    <div class="flex items-end">
                        <button type="button" id="clearPin"
                                class="w-full bg-gray-100 hover:bg-gray-200 text-gray-600 font-semibold px-3 py-2.5 rounded-xl text-sm transition-colors">
                            🗑️ إزالة التحديد
                        </button>
                    </div>
                </div>
            </div>

            {{-- Bio --}}
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
                <h3 class="font-bold text-sm text-gray-700 mb-4">النبذة التعريفية</h3>
                <div class="space-y-4">
                    <div>
                        <label class="text-xs text-gray-500 font-semibold block mb-1">النبذة (عربي)</label>
                        <textarea name="bio" rows="4"
                                  class="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm focus:outline-none focus:border-[#1B5E7B] resize-none">{{ old('bio', $therapist->bio) }}</textarea>
                    </div>
                    <div>
                        <label class="text-xs text-gray-500 font-semibold block mb-1">النبذة (إنجليزي)</label>
                        <textarea name="bio_en" rows="4"
                                  class="w-full border border-gray-200 rounded-xl px-3 py-2.5 text-sm focus:outline-none focus:border-[#1B5E7B] resize-none">{{ old('bio_en', $therapist->bio_en) }}</textarea>
                    </div>
                </div>
            </div>

            {{-- Specializations --}}
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
                <h3 class="font-bold text-sm text-gray-700 mb-4">التخصصات</h3>
                <div class="grid grid-cols-2 sm:grid-cols-3 gap-2">
                    @foreach($allSpecializations as $spec)
                        <label class="flex items-center gap-2 cursor-pointer bg-gray-50 hover:bg-blue-50 border border-gray-100 hover:border-blue-200 rounded-xl px-3 py-2.5 transition-all">
                            <input type="checkbox" name="specializations[]" value="{{ $spec->id }}"
                                   {{ $therapist->specializations->contains($spec->id) ? 'checked' : '' }}
                                   class="w-4 h-4 accent-[#1B5E7B]">
                            <span class="text-sm text-gray-700 font-medium">{{ $spec->name_ar }}</span>
                        </label>
                    @endforeach
                </div>
            </div>

            {{-- Save Button --}}
            <div class="flex gap-3">
                <button type="submit"
                        class="bg-[#1B5E7B] hover:bg-[#154d66] text-white font-bold px-8 py-3 rounded-xl transition-colors shadow-sm">
                    💾 حفظ التعديلات
                </button>
                <a href="{{ route('admin.therapists.show', $therapist) }}"
                   class="bg-gray-100 hover:bg-gray-200 text-gray-700 font-bold px-6 py-3 rounded-xl transition-colors">
                    إلغاء
                </a>
            </div>
        </div>
    </div>
</form>
@endsection

@push('scripts')
<script>
// ── Location picker ──────────────────────────────────────────────
// Centre on the saved pin when there is one, otherwise on the therapist's city,
// otherwise on the West Bank. Writing to the lat/lng inputs is what actually
// saves — the map is just a friendlier way to fill them in.
const CITY_COORDS = {
    'القدس':      { lat: 31.7683, lng: 35.2137 },
    'رام الله':   { lat: 31.8996, lng: 35.2042 },
    'البيرة':     { lat: 31.9067, lng: 35.2172 },
    'نابلس':      { lat: 32.2211, lng: 35.2544 },
    'الخليل':     { lat: 31.5326, lng: 35.0998 },
    'بيت لحم':    { lat: 31.7054, lng: 35.2024 },
    'جنين':       { lat: 32.4607, lng: 35.2966 },
    'طولكرم':     { lat: 32.3100, lng: 35.0295 },
    'قلقيلية':    { lat: 32.1875, lng: 34.9706 },
    'أريحا':      { lat: 31.8561, lng: 35.4617 },
    'طوباس':      { lat: 32.3209, lng: 35.3726 },
    'سلفيت':      { lat: 32.0833, lng: 35.1747 },
    'غزة':        { lat: 31.5017, lng: 34.4668 },
    'خان يونس':   { lat: 31.3452, lng: 34.3028 },
    'رفح':        { lat: 31.2965, lng: 34.2531 },
    'حيفا':       { lat: 32.7940, lng: 34.9896 },
    'الناصرة':    { lat: 32.7021, lng: 35.2978 },
    'عكا':        { lat: 32.9281, lng: 35.0818 },
    'أم الفحم':   { lat: 32.5197, lng: 35.1519 },
};

const SAVED_LAT = @json($therapist->latitude ? (float) $therapist->latitude : null);
const SAVED_LNG = @json($therapist->longitude ? (float) $therapist->longitude : null);
const CITY_NAME = @json($therapist->city);

let pickMap, pin;

function initPickMap() {
    const latInput = document.getElementById('latInput');
    const lngInput = document.getElementById('lngInput');

    let center = { lat: 31.9522, lng: 35.2332 };  // West Bank fallback
    let hasPin = false;

    if (SAVED_LAT !== null && SAVED_LNG !== null) {
        center = { lat: SAVED_LAT, lng: SAVED_LNG };
        hasPin = true;
    } else if (CITY_NAME && CITY_COORDS[CITY_NAME.trim()]) {
        center = CITY_COORDS[CITY_NAME.trim()];
    }

    pickMap = new google.maps.Map(document.getElementById('adminPickMap'), {
        center,
        zoom: hasPin ? 15 : 12,
        mapTypeControl: false,
        streetViewControl: false,
    });

    function setPin(pos) {
        if (!pin) {
            pin = new google.maps.Marker({
                position: pos,
                map: pickMap,
                draggable: true,
                animation: google.maps.Animation.DROP,
            });
            pin.addListener('dragend', (e) => writeInputs(e.latLng));
        } else {
            pin.setPosition(pos);
        }
        writeInputs(new google.maps.LatLng(pos.lat, pos.lng));
    }

    function writeInputs(latLng) {
        latInput.value = latLng.lat().toFixed(6);
        lngInput.value = latLng.lng().toFixed(6);
    }

    if (hasPin) setPin(center);

    pickMap.addListener('click', (e) => {
        setPin({ lat: e.latLng.lat(), lng: e.latLng.lng() });
    });

    // Typing coordinates by hand should move the pin too.
    [latInput, lngInput].forEach((input) => {
        input.addEventListener('change', () => {
            const lat = parseFloat(latInput.value);
            const lng = parseFloat(lngInput.value);
            if (!isNaN(lat) && !isNaN(lng)) {
                const pos = { lat, lng };
                if (!pin) setPin(pos); else pin.setPosition(pos);
                pickMap.panTo(pos);
            }
        });
    });

    document.getElementById('clearPin').addEventListener('click', () => {
        latInput.value = '';
        lngInput.value = '';
        if (pin) { pin.setMap(null); pin = null; }
    });
}
</script>
<script async defer
    src="https://maps.googleapis.com/maps/api/js?key=AIzaSyAFNVsGt3bpV9z9SDwzSPX4uU5s8w-zBYA&callback=initPickMap&language=ar&region=PS"></script>
@endpush
