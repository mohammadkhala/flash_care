@extends('layouts.admin')
@section('title', 'خريطة الأخصائيين')
@section('subtitle', 'توزيع الأخصائيين الجغرافي')

@section('content')

{{-- ── Stats bar ──────────────────────────────────────────────────────────── --}}
<div class="grid grid-cols-2 sm:grid-cols-4 gap-4 mb-5">
    @php
        $total    = $therapists->count();
        $approved = $therapists->where('status','approved')->count();
        $pending  = $therapists->where('status','pending')->count();
        $cities   = $cityCounts->count();
    @endphp
    <div class="bg-white rounded-2xl p-4 border border-gray-100 shadow-sm flex items-center gap-3">
        <div class="w-10 h-10 rounded-xl bg-blue-50 flex items-center justify-center text-xl">📍</div>
        <div><div class="text-2xl font-black text-gray-800">{{ $total }}</div><div class="text-xs text-gray-500">إجمالي على الخريطة</div></div>
    </div>
    <div class="bg-white rounded-2xl p-4 border border-gray-100 shadow-sm flex items-center gap-3">
        <div class="w-10 h-10 rounded-xl bg-green-50 flex items-center justify-center text-xl">✅</div>
        <div><div class="text-2xl font-black text-green-600">{{ $approved }}</div><div class="text-xs text-gray-500">موثق</div></div>
    </div>
    <div class="bg-white rounded-2xl p-4 border border-gray-100 shadow-sm flex items-center gap-3">
        <div class="w-10 h-10 rounded-xl bg-yellow-50 flex items-center justify-center text-xl">⏳</div>
        <div><div class="text-2xl font-black text-yellow-600">{{ $pending }}</div><div class="text-xs text-gray-500">بانتظار الموافقة</div></div>
    </div>
    <div class="bg-white rounded-2xl p-4 border border-gray-100 shadow-sm flex items-center gap-3">
        <div class="w-10 h-10 rounded-xl bg-purple-50 flex items-center justify-center text-xl">🏙️</div>
        <div><div class="text-2xl font-black text-purple-600">{{ $cities }}</div><div class="text-xs text-gray-500">مدينة</div></div>
    </div>
</div>

{{-- ── Loading indicator ──────────────────────────────────────────────────── --}}
<div id="geocodeLoader"
     class="flex items-center gap-3 mb-3 bg-blue-50 border border-blue-100 text-blue-700 px-4 py-2.5 rounded-xl text-sm"
     style="display:none!important">
    <svg class="animate-spin w-4 h-4" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"/>
    </svg>
    جارٍ تحديد مواقع الأخصائيين على الخريطة...
</div>

{{-- ── Main layout ────────────────────────────────────────────────────────── --}}
<div class="flex gap-5" style="height:calc(100vh - 270px);min-height:480px;">

    {{-- Map --}}
    <div class="flex-1 bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden relative">

        {{-- Filters --}}
        <div class="absolute top-3 right-3 z-10 flex gap-2">
            <button onclick="filterMap('all')"      id="btn-all"
                class="filter-btn px-3 py-1.5 rounded-xl text-xs font-bold shadow bg-[#1B2E6E] text-white transition-all">
                الكل ({{ $total }})
            </button>
            <button onclick="filterMap('approved')" id="btn-approved"
                class="filter-btn px-3 py-1.5 rounded-xl text-xs font-bold shadow bg-white text-gray-600 hover:bg-green-50 transition-all">
                موثق ({{ $approved }})
            </button>
            <button onclick="filterMap('pending')"  id="btn-pending"
                class="filter-btn px-3 py-1.5 rounded-xl text-xs font-bold shadow bg-white text-gray-600 hover:bg-yellow-50 transition-all">
                معلق ({{ $pending }})
            </button>
        </div>

        <div id="map" style="width:100%;height:100%;"></div>
    </div>

    {{-- City sidebar --}}
    <div class="w-60 bg-white rounded-2xl border border-gray-100 shadow-sm flex flex-col overflow-hidden flex-shrink-0">
        <div class="p-4 border-b border-gray-100">
            <h3 class="font-bold text-sm text-gray-800">التوزيع حسب المدينة</h3>
        </div>
        <div class="flex-1 overflow-y-auto p-3 space-y-1">
            @forelse($cityCounts as $city => $count)
                <button onclick="focusCity('{{ addslashes($city) }}')"
                        class="w-full flex items-center justify-between px-3 py-2.5 rounded-xl
                               hover:bg-gray-50 transition-colors text-right group">
                    <span class="text-sm text-gray-700 group-hover:text-[#1B2E6E] font-medium">{{ $city }}</span>
                    <span class="text-xs font-bold px-2 py-0.5 rounded-full bg-[#1B2E6E]/10 text-[#1B2E6E]">{{ $count }}</span>
                </button>
            @empty
                <p class="text-xs text-gray-400 text-center py-4">لا توجد بيانات</p>
            @endforelse
        </div>
        <div class="p-4 border-t border-gray-100 space-y-2">
            <p class="text-xs font-semibold text-gray-500 mb-1">الدلالة</p>
            <div class="flex items-center gap-2"><span class="w-3 h-3 rounded-full bg-green-500 inline-block"></span><span class="text-xs text-gray-600">موثق</span></div>
            <div class="flex items-center gap-2"><span class="w-3 h-3 rounded-full bg-amber-400 inline-block"></span><span class="text-xs text-gray-600">بانتظار الموافقة</span></div>
            <div class="flex items-center gap-2"><span class="w-3 h-3 rounded-full bg-red-400 inline-block"></span><span class="text-xs text-gray-600">مرفوض / معطل</span></div>
        </div>
    </div>
</div>

@endsection

@push('scripts')
<script>
const THERAPISTS = @json($therapists);

const STATUS_COLORS = {
    approved : '#22c55e',
    pending  : '#f59e0b',
    rejected : '#ef4444',
    default  : '#6b7280',
};

// Pre-defined coordinates for common Palestinian cities (fallback)
const CITY_COORDS = {
    'القدس'       : { lat: 31.7683, lng: 35.2137 },
    'رام الله'    : { lat: 31.8996, lng: 35.2042 },
    'نابلس'       : { lat: 32.2211, lng: 35.2544 },
    'الخليل'      : { lat: 31.5326, lng: 35.0998 },
    'بيت لحم'     : { lat: 31.7054, lng: 35.2024 },
    'جنين'        : { lat: 32.4607, lng: 35.2966 },
    'طولكرم'      : { lat: 32.3100, lng: 35.0295 },
    'قلقيلية'     : { lat: 32.1875, lng: 34.9706 },
    'أريحا'       : { lat: 31.8561, lng: 35.4617 },
    'طوباس'       : { lat: 32.3209, lng: 35.3726 },
    'سلفيت'       : { lat: 32.0833, lng: 35.1747 },
    'غزة'         : { lat: 31.5017, lng: 34.4668 },
    'خان يونس'    : { lat: 31.3452, lng: 34.3028 },
    'رفح'         : { lat: 31.2965, lng: 34.2531 },
    'حيفا'        : { lat: 32.7940, lng: 34.9896 },
    'تل أبيب'     : { lat: 32.0853, lng: 34.7818 },
    'عمان'        : { lat: 31.9539, lng: 35.9106 },
    'بيروت'       : { lat: 33.8938, lng: 35.5018 },
};

let map, geocoder, infoWindow;
const allMarkers   = [];        // { marker, status, city }
const geocodeCache = {};        // city → { lat, lng }

function initMap() {
    map = new google.maps.Map(document.getElementById('map'), {
        zoom: 8,
        center: { lat: 31.95, lng: 35.23 },
        mapTypeId: 'roadmap',
        streetViewControl: false,
        fullscreenControl: true,
        mapTypeControl: false,
        zoomControlOptions: { position: google.maps.ControlPosition.LEFT_CENTER },
        styles: [
            { featureType: 'poi', elementType: 'labels', stylers: [{ visibility: 'off' }] },
        ],
    });

    geocoder   = new google.maps.Geocoder();
    infoWindow = new google.maps.InfoWindow({ maxWidth: 280 });

    placeAllTherapists();
}

// ── Place all therapists on the map ─────────────────────────────────────────
async function placeAllTherapists() {
    // Show loading if geocoding needed
    const needGeocode = THERAPISTS.some(t => t.clinics.some(c => !c.lat || !c.lng));
    if (needGeocode) {
        document.getElementById('geocodeLoader').style.removeProperty('display');
    }

    const bounds = new google.maps.LatLngBounds();
    let hasAny = false;

    for (const t of THERAPISTS) {
        for (const c of t.clinics) {
            let lat = c.lat, lng = c.lng;

            // If no coordinates → geocode the city
            if (!lat || !lng) {
                const coords = await resolveCity(c.city || t.city);
                if (!coords) continue;
                // Add tiny random offset so same-city markers don't stack
                lat = coords.lat + (Math.random() - 0.5) * 0.015;
                lng = coords.lng + (Math.random() - 0.5) * 0.015;
            }

            placeMarker(t, c, lat, lng);
            bounds.extend({ lat, lng });
            hasAny = true;
        }
    }

    document.getElementById('geocodeLoader').style.display = 'none';

    if (hasAny) {
        map.fitBounds(bounds, { top: 60, right: 60, bottom: 40, left: 40 });
    }
}

// ── Resolve city name → coordinates ─────────────────────────────────────────
function resolveCity(city) {
    if (!city) return Promise.resolve(null);

    // 1. Pre-defined lookup
    const predef = Object.entries(CITY_COORDS).find(([k]) => city.includes(k));
    if (predef) return Promise.resolve({ lat: predef[1].lat, lng: predef[1].lng });

    // 2. Cache
    if (geocodeCache[city]) return Promise.resolve(geocodeCache[city]);

    // 3. Google Geocoder
    return new Promise(resolve => {
        geocoder.geocode({ address: city + '، فلسطين' }, (results, status) => {
            if (status === 'OK' && results[0]) {
                const loc = results[0].geometry.location;
                const coords = { lat: loc.lat(), lng: loc.lng() };
                geocodeCache[city] = coords;
                resolve(coords);
            } else {
                // Try without country
                geocoder.geocode({ address: city }, (r2, s2) => {
                    if (s2 === 'OK' && r2[0]) {
                        const loc2 = r2[0].geometry.location;
                        const coords2 = { lat: loc2.lat(), lng: loc2.lng() };
                        geocodeCache[city] = coords2;
                        resolve(coords2);
                    } else {
                        resolve(null);
                    }
                });
            }
        });
    });
}

// ── Place a single marker ────────────────────────────────────────────────────
function placeMarker(t, c, lat, lng) {
    const color    = STATUS_COLORS[t.status] || STATUS_COLORS.default;
    const initials = t.name ? t.name.charAt(0) : '؟';

    const svg = btoa(unescape(encodeURIComponent(
        `<svg xmlns="http://www.w3.org/2000/svg" width="44" height="54" viewBox="0 0 44 54">
            <defs>
                <filter id="sh" x="-20%" y="-20%" width="140%" height="140%">
                    <feDropShadow dx="0" dy="2" stdDeviation="2.5" flood-color="#00000040"/>
                </filter>
            </defs>
            <path d="M22 1C10.95 1 2 9.95 2 21c0 16.5 20 32 20 32S42 37.5 42 21C42 9.95 33.05 1 22 1z"
                  fill="${color}" filter="url(#sh)"/>
            <circle cx="22" cy="21" r="13" fill="white"/>
            <text x="22" y="26" text-anchor="middle" font-size="14"
                  font-family="Cairo,Arial" font-weight="800" fill="${color}">${initials}</text>
        </svg>`
    )));

    const marker = new google.maps.Marker({
        position : { lat, lng },
        map,
        icon: {
            url         : `data:image/svg+xml;base64,${svg}`,
            scaledSize  : new google.maps.Size(44, 54),
            anchor      : new google.maps.Point(22, 54),
        },
        title     : t.name,
        animation : google.maps.Animation.DROP,
    });

    marker.addListener('click', () => {
        const stars      = '★'.repeat(Math.round(t.rating)) + '☆'.repeat(5 - Math.round(t.rating));
        const badgeStyle = t.status === 'approved'
            ? 'background:#dcfce7;color:#16a34a'
            : t.status === 'pending'
                ? 'background:#fef9c3;color:#ca8a04'
                : 'background:#fee2e2;color:#dc2626';
        const badgeTxt   = t.status === 'approved' ? 'موثق' : t.status === 'pending' ? 'معلق' : 'مرفوض';
        const geocoded   = (!c.lat || !c.lng)
            ? '<div style="font-size:10px;color:#999;margin-bottom:4px">📡 موقع تقريبي (المدينة)</div>' : '';

        infoWindow.setContent(`
            <div style="font-family:Cairo,sans-serif;direction:rtl;padding:4px 2px;min-width:220px">
                ${geocoded}
                <div style="display:flex;align-items:center;gap:10px;margin-bottom:10px">
                    <div style="width:44px;height:44px;border-radius:12px;flex-shrink:0;
                                background:linear-gradient(135deg,#1B2E6E,#2D4A9E);
                                display:flex;align-items:center;justify-content:center;
                                color:white;font-weight:800;font-size:20px">
                        ${initials}
                    </div>
                    <div>
                        <div style="font-weight:700;font-size:15px;color:#111">${t.name}</div>
                        <div style="font-size:11px;color:#888;margin-top:1px">${t.specializations || '—'}</div>
                    </div>
                </div>
                <div style="font-size:12px;color:#555;margin-bottom:3px">🏥 <b>${c.name}</b></div>
                <div style="font-size:12px;color:#666;margin-bottom:8px">📍 ${c.address}، ${c.city}</div>
                <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:10px">
                    <span style="color:#f59e0b;font-size:14px">${stars}</span>
                    <span style="padding:3px 10px;border-radius:99px;font-size:11px;font-weight:700;${badgeStyle}">${badgeTxt}</span>
                </div>
                <a href="/admin/therapists/${t.id}"
                   style="display:block;text-align:center;padding:8px;border-radius:10px;font-size:13px;
                          font-weight:600;text-decoration:none;color:white;
                          background:linear-gradient(135deg,#1B2E6E,#2D4A9E)">
                    عرض الملف الكامل ←
                </a>
            </div>`);

        infoWindow.open(map, marker);
    });

    allMarkers.push({ marker, status: t.status, city: t.city });
}

// ── Filter markers by status ─────────────────────────────────────────────────
function filterMap(status) {
    infoWindow.close();
    allMarkers.forEach(({ marker, status: s }) => {
        marker.setVisible(status === 'all' || s === status);
    });
    document.querySelectorAll('.filter-btn').forEach(b => {
        b.style.background = '#fff';
        b.style.color      = '#4b5563';
    });
    const btn = document.getElementById('btn-' + status);
    if (btn) { btn.style.background = '#1B2E6E'; btn.style.color = '#fff'; }
}

// ── Focus on a city ──────────────────────────────────────────────────────────
async function focusCity(city) {
    infoWindow.close();
    filterMap('all');

    const cityMarkers = allMarkers.filter(m => m.city === city);

    if (cityMarkers.length === 1) {
        const pos = cityMarkers[0].marker.getPosition();
        map.panTo(pos);
        map.setZoom(14);
        cityMarkers[0].marker.setAnimation(google.maps.Animation.BOUNCE);
        setTimeout(() => cityMarkers[0].marker.setAnimation(null), 2000);
    } else if (cityMarkers.length > 1) {
        const bounds = new google.maps.LatLngBounds();
        cityMarkers.forEach(m => bounds.extend(m.marker.getPosition()));
        map.fitBounds(bounds, { top: 80, right: 80, bottom: 60, left: 60 });
    } else {
        // Fallback: geocode the city and pan there
        const coords = await resolveCity(city);
        if (coords) { map.panTo(coords); map.setZoom(13); }
    }
}
</script>

<script async
    src="https://maps.googleapis.com/maps/api/js?key=AIzaSyAFNVsGt3bpV9z9SDwzSPX4uU5s8w-zBYA&callback=initMap&language=ar&region=PS">
</script>
@endpush
