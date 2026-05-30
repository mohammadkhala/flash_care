<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>تسجيل الدخول - NABD CARE</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700;800;900&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Cairo', sans-serif; }
        .heartbeat-line { stroke-dasharray: 300; stroke-dashoffset: 300; animation: draw 1.5s ease forwards 0.3s; }
        @keyframes draw { to { stroke-dashoffset: 0; } }
        .logo-scale { animation: scaleIn 0.6s cubic-bezier(0.34,1.56,0.64,1) forwards; opacity: 0; }
        @keyframes scaleIn { to { opacity: 1; transform: scale(1); } from { transform: scale(0.6); } }
    </style>
</head>
<body class="min-h-screen flex items-center justify-center p-4" style="background: linear-gradient(135deg, #0F1D48 0%, #1B2E6E 55%, #2D4A9E 100%);">

<div class="w-full max-w-md">

    {{-- Logo --}}
    <div class="text-center mb-8 logo-scale">
        {{-- Heartbeat SVG --}}
        <svg viewBox="0 0 200 40" class="w-48 mx-auto mb-2" fill="none">
            <line x1="0" y1="20" x2="40" y2="20" stroke="#D42B24" stroke-width="2.5" stroke-linecap="round"/>
            <polyline points="40,20 55,4 62,36 72,10 80,26 90,20 200,20"
                      stroke="#D42B24" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"
                      class="heartbeat-line" fill="none"/>
        </svg>

        {{-- NABD CARE text --}}
        <div class="flex items-end justify-center gap-3">
            <div class="text-left">
                <div class="text-white font-black tracking-widest leading-none" style="font-size: 2rem;">NABD</div>
                <div class="font-black tracking-widest leading-none" style="font-size: 2rem; color: #D42B24;">CARE</div>
            </div>
            {{-- Wheelchair icon (SVG) --}}
            <svg viewBox="0 0 40 50" class="w-10 h-12 mb-1" fill="none">
                <circle cx="24" cy="6"  r="5"  fill="#8FA0AD"/>
                <path d="M24 12 L20 28 L34 28 L34 36 L20 36" stroke="#8FA0AD" stroke-width="3" stroke-linecap="round" fill="none"/>
                <circle cx="18" cy="38" r="10" stroke="#2D4A9E" stroke-width="3" fill="none"/>
                <circle cx="34" cy="42" r="4"  stroke="#2D4A9E" stroke-width="3" fill="none"/>
            </svg>
        </div>
        <p class="text-white/60 text-sm mt-3">لوحة إدارة المنصة</p>
    </div>

    {{-- Card --}}
    <div class="bg-white rounded-2xl shadow-2xl p-8">

        @if($errors->any())
            <div class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl mb-6 text-sm flex items-center gap-2">
                <span>⚠️</span> {{ $errors->first() }}
            </div>
        @endif

        <h2 class="text-xl font-bold mb-6" style="color: #1B2E6E;">تسجيل الدخول</h2>

        <form method="POST" action="{{ route('login') }}" class="space-y-5">
            @csrf

            <div>
                <label class="block text-sm font-semibold text-gray-600 mb-2">رقم الهاتف</label>
                <input type="text" name="phone" value="{{ old('phone') }}"
                       class="w-full border border-gray-200 rounded-xl px-4 py-3 text-sm transition-all outline-none"
                       style="--tw-ring-color: #1B2E6E20;"
                       onfocus="this.style.borderColor='#1B2E6E'; this.style.boxShadow='0 0 0 3px #1B2E6E18';"
                       onblur="this.style.borderColor=''; this.style.boxShadow='';"
                       placeholder="5XXXXXXXX" required autofocus>
            </div>

            <div>
                <label class="block text-sm font-semibold text-gray-600 mb-2">كلمة المرور</label>
                <input type="password" name="password"
                       class="w-full border border-gray-200 rounded-xl px-4 py-3 text-sm transition-all outline-none"
                       onfocus="this.style.borderColor='#1B2E6E'; this.style.boxShadow='0 0 0 3px #1B2E6E18';"
                       onblur="this.style.borderColor=''; this.style.boxShadow='';"
                       placeholder="••••••••" required>
            </div>

            <label class="flex items-center gap-2 text-sm text-gray-600 cursor-pointer">
                <input type="checkbox" name="remember" class="rounded accent-[#1B2E6E]">
                تذكرني
            </label>

            <button type="submit"
                    class="w-full text-white font-bold py-3 rounded-xl transition-all shadow-lg hover:shadow-xl hover:opacity-90"
                    style="background: linear-gradient(135deg, #1B2E6E, #2D4A9E);">
                دخول للوحة الإدارة
            </button>
        </form>
    </div>

    <p class="text-center text-white/30 text-xs mt-6">NABD CARE © {{ date('Y') }} - جميع الحقوق محفوظة</p>
</div>

</body>
</html>
