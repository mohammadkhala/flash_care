<!DOCTYPE html>
<html id="rootHtml" lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>نبض — منصة العلاج الطبيعي والوظيفي في فلسطين</title>
    <meta name="description" content="نبض — منصة تربط المرضى بأفضل أخصائيي العلاج الطبيعي والوظيفي في فلسطين. احجز جلستك الآن بسهولة وأمان.">
    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@300;400;500;600;700;800;900&family=Heebo:wght@400;500;700;800;900&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        * { font-family: 'Cairo', sans-serif; scroll-behavior: smooth; }

        .grad-hero   { background: linear-gradient(145deg, #050D1A 0%, #0B1F3A 40%, #0F2E5A 80%, #0B3D5C 100%); }
        .grad-card   { background: linear-gradient(135deg, rgba(255,255,255,0.06) 0%, rgba(255,255,255,0.02) 100%); }
        .grad-green  { background: linear-gradient(135deg, #064E3B 0%, #065F46 100%); }
        .grad-red    { background: linear-gradient(135deg, #7A1010 0%, #D42B24 100%); }
        .grad-blue   { background: linear-gradient(135deg, #1E3A5F 0%, #1B5E7B 100%); }
        .grad-teal   { background: linear-gradient(135deg, #0F3D52 0%, #1B5E7B 100%); }
        .grad-purple { background: linear-gradient(135deg, #2D1B5E 0%, #5B3FA6 100%); }
        .grad-orange { background: linear-gradient(135deg, #7C2D12 0%, #EA580C 100%); }

        /* Phone frame */
        .phone-frame {
            width: 200px; height: 400px;
            border-radius: 36px;
            background: #080C14;
            border: 5px solid #1E2D40;
            box-shadow: 0 40px 80px rgba(0,0,0,0.7), inset 0 0 0 1px rgba(255,255,255,0.05);
            position: relative; overflow: hidden; flex-shrink: 0;
        }
        .phone-frame::before {
            content: '';
            position: absolute; top: 10px; left: 50%; transform: translateX(-50%);
            width: 55px; height: 5px;
            background: #111820; border-radius: 99px; z-index: 10;
        }
        /* Status bar dots */
        .phone-frame::after {
            content: '●●●';
            position: absolute; top: 8px; right: 14px;
            font-size: 4px; letter-spacing: 2px;
            color: rgba(255,255,255,0.3); z-index: 10;
        }
        .phone-screen { width:100%; height:100%; overflow:hidden; }

        /* Bottom nav bar inside phone */
        .phone-nav {
            display: flex; align-items: center; justify-content: space-around;
            background: rgba(10,14,22,0.95);
            border-top: 1px solid rgba(255,255,255,0.07);
            padding: 6px 4px 8px;
            flex-shrink: 0;
        }
        .phone-nav-item { display: flex; flex-direction: column; align-items: center; gap: 2px; }
        .phone-nav-icon { font-size: 14px; }
        .phone-nav-label { font-size: 5px; color: rgba(255,255,255,0.4); }
        .phone-nav-item.active .phone-nav-label { color: #D42B24; }

        @keyframes float  { 0%,100%{transform:translateY(0)} 50%{transform:translateY(-14px)} }
        @keyframes float2 { 0%,100%{transform:translateY(0) rotate(-3deg)} 50%{transform:translateY(-10px) rotate(-3deg)} }
        .float  { animation: float  4s ease-in-out infinite; }
        .float2 { animation: float2 5s ease-in-out infinite 1s; }
        .float3 { animation: float  6s ease-in-out infinite 2s; }

        @keyframes pulse-dot { 0%,100%{opacity:1;transform:scale(1)} 50%{opacity:.5;transform:scale(1.4)} }
        .pulse-dot { animation: pulse-dot 2s ease-in-out infinite; }

        .hb-line { stroke-dasharray:400; stroke-dashoffset:400; animation:draw-hb 2s ease forwards 0.5s; }
        @keyframes draw-hb { to { stroke-dashoffset:0; } }

        .glow-red  { box-shadow: 0 0 40px rgba(212,43,36,.35); }
        .glow-blue { box-shadow: 0 0 40px rgba(27,94,123,.4); }

        .glass { background:rgba(255,255,255,0.04); backdrop-filter:blur(20px); border:1px solid rgba(255,255,255,0.08); }

        .fade-up { opacity:0; transform:translateY(30px); transition:opacity .7s ease, transform .7s ease; }
        .fade-up.visible { opacity:1; transform:translateY(0); }

        .grad-text {
            background: linear-gradient(90deg, #fff 0%, #93C5FD 50%, #D42B24 100%);
            -webkit-background-clip:text; -webkit-text-fill-color:transparent; background-clip:text;
        }
        .grad-text-red {
            background: linear-gradient(90deg, #D42B24, #FF7B6B);
            -webkit-background-clip:text; -webkit-text-fill-color:transparent; background-clip:text;
        }
        .grad-text-blue {
            background: linear-gradient(90deg, #60A5FA, #38BDF8);
            -webkit-background-clip:text; -webkit-text-fill-color:transparent; background-clip:text;
        }

        .nav-blur { backdrop-filter:blur(20px); background:rgba(5,13,26,0.85); border-bottom:1px solid rgba(255,255,255,0.07); }

        /* Language switcher */
        .lang-btn { color: rgba(255,255,255,0.5); }
        .lang-btn:hover { color: rgba(255,255,255,0.9); background: rgba(255,255,255,0.06); }
        .lang-btn.active { background: #D42B24; color: #fff; }
        /* Hebrew font when active */
        html[lang="he"] * { font-family: 'Heebo', 'Cairo', sans-serif; }
        html[lang="en"] * { font-family: 'Cairo', sans-serif; }
        .stat-num { font-size:2.8rem; font-weight:900; line-height:1; }

        /* Appointment status badges */
        .badge-confirmed { background:rgba(34,197,94,.15); color:#4ADE80; border:1px solid rgba(34,197,94,.25); }
        .badge-pending   { background:rgba(245,158,11,.15); color:#FCD34D; border:1px solid rgba(245,158,11,.25); }
        .badge-online    { background:rgba(56,189,248,.15); color:#7DD3FC; border:1px solid rgba(56,189,248,.25); }
        .badge-inperson  { background:rgba(167,139,250,.15); color:#C4B5FD; border:1px solid rgba(167,139,250,.25); }
    </style>
</head>
<body class="bg-[#050D1A] text-white overflow-x-hidden">

{{-- ════ NAV ════ --}}
<nav class="fixed top-0 inset-x-0 z-50 nav-blur">
    <div class="max-w-6xl mx-auto px-5 h-16 flex items-center justify-between">
        {{-- ── NABD CARE Logo ── --}}
        <a href="#" class="flex items-center gap-1.5">
            {{-- Heartbeat line --}}
            <svg viewBox="0 0 100 20" class="h-5 w-[68px]" fill="none">
                <polyline points="0,10 25,10 35,1 42,19 50,4 57,14 63,10 100,10"
                          stroke="#D42B24" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            {{-- NABD / CARE stacked --}}
            <div class="font-black tracking-widest leading-none select-none">
                <div class="text-white" style="font-size:13px;line-height:1.05">NABD</div>
                <div style="color:#D42B24;font-size:13px;line-height:1.05">CARE</div>
            </div>
            {{-- Wheelchair mark --}}
            <svg viewBox="0 0 40 50" class="h-8 w-6 opacity-80" fill="none">
                <circle cx="22" cy="5" r="5" fill="#9CA3AF"/>
                <path d="M22 11 L19 27 L34 27 L34 33 L19.5 33" stroke="#9CA3AF" stroke-width="2.4" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M28.5 49.5 A14 14 0 1 1 28.5 34" stroke="#1B5E7B" stroke-width="2.6" fill="none" stroke-linecap="round"/>
                <circle cx="33" cy="44" r="3.6" stroke="#1B5E7B" stroke-width="2.2" fill="none"/>
            </svg>
        </a>
        <div class="flex items-center gap-3">
            <div class="hidden md:flex items-center gap-6 text-sm font-semibold text-white/70">
                <a href="#about"    class="hover:text-white transition-colors" data-i18n="navAbout">عن المنصة</a>
                <a href="#features" class="hover:text-white transition-colors" data-i18n="navFeatures">المميزات</a>
                <a href="#screens"  class="hover:text-white transition-colors" data-i18n="navScreens">الشاشات</a>
                <a href="#download" class="hover:text-white transition-colors" data-i18n="navDownload">تحميل</a>
            </div>
            {{-- Language switcher --}}
            <div class="flex items-center bg-white/6 border border-white/12 rounded-lg overflow-hidden text-xs font-bold">
                <button onclick="setLang('ar')" data-lang-btn="ar" class="lang-btn px-2.5 py-1.5 transition-colors">ع</button>
                <button onclick="setLang('he')" data-lang-btn="he" class="lang-btn px-2.5 py-1.5 transition-colors border-x border-white/10">עב</button>
                <button onclick="setLang('en')" data-lang-btn="en" class="lang-btn px-2.5 py-1.5 transition-colors">EN</button>
            </div>
            <a href="/admin"
               class="hidden md:inline-block bg-white/8 hover:bg-white/15 border border-white/12 text-white px-4 py-1.5 rounded-lg transition-all text-xs">
                🔐 <span data-i18n="navAdmin">لوحة الإدارة</span>
            </a>
            <a href="/admin" class="md:hidden text-xs bg-white/8 border border-white/12 px-3 py-1.5 rounded-lg">🔐 <span data-i18n="navAdminShort">الإدارة</span></a>
        </div>
    </div>
</nav>

{{-- ════ HERO ════ --}}
<section class="grad-hero min-h-screen flex flex-col items-center justify-center pt-16 px-5 relative overflow-hidden">
    <div class="absolute top-1/4 right-1/4 w-96 h-96 rounded-full opacity-8"
         style="background:radial-gradient(circle,#1B5E7B,transparent);filter:blur(80px)"></div>
    <div class="absolute bottom-1/3 left-1/5 w-80 h-80 rounded-full opacity-8"
         style="background:radial-gradient(circle,#D42B24,transparent);filter:blur(80px)"></div>

    <div class="max-w-6xl w-full mx-auto grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
        {{-- Text --}}
        <div class="text-center lg:text-right order-2 lg:order-1">
            <div class="inline-flex items-center gap-2 bg-white/6 border border-white/10 rounded-full px-4 py-2 text-sm mb-6">
                <span class="pulse-dot w-2 h-2 bg-[#38BDF8] rounded-full inline-block"></span>
                <span data-i18n="heroBadge">المنصة الأولى للعلاج الطبيعي والوظيفي في فلسطين</span>
            </div>

            <h1 class="text-5xl md:text-6xl font-black leading-tight mb-6" data-i18n="heroH1">
                طريقك نحو<br>
                <span class="grad-text-red">التعافي الكامل</span>
            </h1>

            <p class="text-white/65 text-lg leading-relaxed mb-8 max-w-md mx-auto lg:mx-0" data-i18n="heroPara">
                نبض يربطك بأفضل أخصائيي العلاج الطبيعي والوظيفي المعتمدين في فلسطين.
                احجز جلستك أونلاين أو حضورياً واتابع تقدمك مع كل جلسة.
            </p>

            <div class="flex flex-wrap gap-3 justify-center lg:justify-start">
                <a href="#download"
                   class="flex items-center gap-2 bg-[#D42B24] hover:bg-[#b82220] px-6 py-3.5 rounded-2xl font-bold text-sm transition-all glow-red hover:scale-105">
                    <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M3.18 23.76c.33.18.7.24 1.06.18L14.93 12 4.24.06C3.88 0 3.51.06 3.18.24 2.49.62 2.07 1.34 2.07 2.15v19.7c0 .81.42 1.53 1.11 1.91zM16.54 13.61l2.93 2.93-8.9 5.01 5.97-7.94zm3.89-2.18c.39.22.63.62.63 1.07s-.24.85-.63 1.07l-2.04 1.15-3.24-3.24 3.24-3.24 2.04 1.19zM11.57 7.45L5.6 2.44l8.87 5.01-2.9 2z"/></svg>
                    <span data-i18n="heroCtaAndroid">تحميل للأندرويد</span>
                </a>
                <a href="#screens"
                   class="flex items-center gap-2 glass hover:bg-white/8 px-6 py-3.5 rounded-2xl font-bold text-sm transition-all hover:scale-105">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                    <span data-i18n="heroCtaWatch">شاهد كيف يعمل</span>
                </a>
            </div>

            {{-- Stats --}}
            <div class="grid grid-cols-3 gap-4 mt-10 pt-8 border-t border-white/10">
                <div class="text-center lg:text-right">
                    <div class="stat-num grad-text-red">+80</div>
                    <div class="text-white/50 text-xs mt-1" data-i18n="heroStat1">أخصائي معتمد</div>
                </div>
                <div class="text-center lg:text-right">
                    <div class="stat-num text-white">+1200</div>
                    <div class="text-white/50 text-xs mt-1" data-i18n="heroStat2">جلسة مكتملة</div>
                </div>
                <div class="text-center lg:text-right">
                    <div class="stat-num grad-text-blue">4.9</div>
                    <div class="text-white/50 text-xs mt-1" data-i18n="heroStat3">تقييم المستخدمين</div>
                </div>
            </div>
        </div>

        {{-- Phone mockups --}}
        <div class="order-1 lg:order-2 flex justify-center items-end gap-5 lg:gap-7 relative h-[430px]">

            {{-- Phone 1 — Patient App (home screen) --}}
            <div class="float2 self-end">
                <div class="phone-frame">
                    <div class="phone-screen flex flex-col" style="background:linear-gradient(175deg,#08152A 0%,#0B1F3A 55%,#0F2E5A 100%)">
                        <div class="flex-1 p-3 pt-7 flex flex-col gap-2 overflow-hidden">
                            {{-- Header --}}
                            <div class="flex items-center justify-between">
                                <div>
                                    <div class="text-[8px] text-white/50">مرحباً 👋</div>
                                    <div class="text-[11px] font-black text-white">محمد أحمد</div>
                                </div>
                                <div class="w-7 h-7 rounded-full" style="background:linear-gradient(135deg,#D42B24,#FF7B6B)">
                                    <div class="w-full h-full flex items-center justify-center text-[9px] font-black">م</div>
                                </div>
                            </div>
                            {{-- Mood --}}
                            <div class="bg-white/5 rounded-xl p-2 border border-white/8">
                                <div class="text-[7px] text-white/50 mb-1">كيف حالك اليوم؟</div>
                                <div class="flex gap-1 justify-around">
                                    @foreach(['😢','😟','😐','🙂','😄'] as $e)
                                        <div class="w-7 h-7 bg-white/5 rounded-lg flex items-center justify-center text-[11px]">{{ $e }}</div>
                                    @endforeach
                                </div>
                            </div>
                            {{-- Next appointment --}}
                            <div class="rounded-xl p-2.5" style="background:rgba(212,43,36,0.12);border:1px solid rgba(212,43,36,0.25)">
                                <div class="text-[7px] text-white/50">موعدك القادم</div>
                                <div class="text-[10px] font-black text-white mt-0.5">د. سارة حداد</div>
                                <div class="text-[7px] text-white/60">غداً • ١٠:٠٠ ص • علاج طبيعي 🏥</div>
                                <div class="flex gap-1 mt-1.5">
                                    <div class="flex-1 bg-[#D42B24] rounded-lg py-1 text-center text-[7px] font-bold">انضم</div>
                                    <div class="flex-1 bg-white/8 rounded-lg py-1 text-center text-[7px] text-white/60">تفاصيل</div>
                                </div>
                            </div>
                            {{-- Featured therapists --}}
                            <div class="text-[7px] text-white/50 font-semibold">أخصائيون مميزون</div>
                            @foreach([
                                ['د. سارة حداد','علاج طبيعي','4.9','D42B24','FF7B6B'],
                                ['د. كريم ناصر','علاج وظيفي','4.8','1B5E7B','2D9EC4'],
                            ] as $d)
                                <div class="bg-white/5 rounded-xl p-2 flex items-center gap-2 border border-white/6">
                                    <div class="w-8 h-8 rounded-xl flex-shrink-0 flex items-center justify-center text-[11px] font-black text-white"
                                         style="background:linear-gradient(135deg,#{{ $d[3] }},#{{ $d[4] }})">{{ mb_substr($d[0],3,1) }}</div>
                                    <div class="flex-1 min-w-0">
                                        <div class="text-[8px] font-bold text-white truncate">{{ $d[0] }}</div>
                                        <div class="text-[7px] text-white/45">{{ $d[1] }}</div>
                                    </div>
                                    <div class="text-[8px] text-yellow-400">⭐{{ $d[2] }}</div>
                                </div>
                            @endforeach
                        </div>
                        {{-- Bottom nav --}}
                        <div class="phone-nav">
                            @foreach([['🏠','الرئيسية',true],['🔍','أخصائيون',false],['📅','مواعيدي',false],['💬','رسائل',false],['👤','حسابي',false]] as $n)
                                <div class="phone-nav-item {{ $n[2]?'active':'' }}">
                                    <span class="phone-nav-icon">{{ $n[0] }}</span>
                                    <span class="phone-nav-label" style="{{ $n[2]?'color:#D42B24':'' }}">{{ $n[1] }}</span>
                                </div>
                            @endforeach
                        </div>
                    </div>
                </div>
                <div class="text-center mt-3 text-xs text-white/35 font-semibold">تطبيق المريض</div>
            </div>

            {{-- Phone 2 — Therapist App (center, bigger) --}}
            <div class="float" style="width:220px">
                <div class="phone-frame glow-blue" style="width:220px;height:445px;border-radius:40px">
                    <div class="phone-screen flex flex-col" style="background:linear-gradient(175deg,#050D1A 0%,#0B1E36 50%,#0F2A4A 100%)">
                        <div class="flex-1 p-3 pt-7 flex flex-col gap-2 overflow-hidden">
                            <div class="flex items-center justify-between">
                                <div>
                                    <div class="text-[8px] text-white/50">لوحة الأخصائي</div>
                                    <div class="text-[11px] font-black text-white">د. أميرة سالم 👩‍⚕️</div>
                                </div>
                                <div class="w-7 h-7 rounded-full flex items-center justify-center text-[9px] font-black text-white"
                                     style="background:linear-gradient(135deg,#1B5E7B,#2D9EC4)">أ</div>
                            </div>
                            {{-- Stats --}}
                            <div class="grid grid-cols-3 gap-1.5">
                                @foreach([['٩','مواعيد اليوم','#D42B24'],['٣٨','هذا الشهر','#1B5E7B'],['4.9','تقييمي','#F59E0B']] as $s)
                                    <div class="rounded-xl p-2 text-center" style="background:{{ $s[2] }}1A;border:1px solid {{ $s[2] }}30">
                                        <div class="text-[13px] font-black" style="color:{{ $s[2] }}">{{ $s[0] }}</div>
                                        <div class="text-[6px] text-white/45 leading-tight">{{ $s[1] }}</div>
                                    </div>
                                @endforeach
                            </div>
                            {{-- Today --}}
                            <div class="text-[8px] font-bold text-white/70">مواعيد اليوم</div>
                            @foreach([
                                ['أحمد محمد','١٠:٠٠ ص','أونلاين','confirmed','badge-online'],
                                ['ليلى خالد','١١:٣٠ ص','حضوري','مؤكد','badge-confirmed'],
                                ['سامر علي','٢:٠٠ م','أونلاين','معلق','badge-pending'],
                            ] as $a)
                                <div class="bg-white/5 rounded-xl p-2 flex items-center gap-2 border border-white/6">
                                    <div class="w-7 h-7 rounded-xl flex-shrink-0 flex items-center justify-center text-[10px] font-black text-white"
                                         style="background:rgba(27,94,123,0.4)">{{ mb_substr($a[0],0,1) }}</div>
                                    <div class="flex-1 min-w-0">
                                        <div class="text-[8px] font-bold text-white truncate">{{ $a[0] }}</div>
                                        <div class="text-[6px] text-white/40">{{ $a[1] }} • {{ $a[2] }}</div>
                                    </div>
                                    <div class="text-[6px] px-1.5 py-0.5 rounded-full {{ $a[4] }}">{{ $a[3]==='confirmed'?'مؤكد':$a[3] }}</div>
                                </div>
                            @endforeach
                            {{-- Reels preview --}}
                            <div class="rounded-xl p-2.5 flex items-center gap-2" style="background:linear-gradient(135deg,#1B5E7B1A,#0F3D521A);border:1px solid rgba(27,94,123,0.2)">
                                <div class="w-8 h-8 rounded-lg flex items-center justify-center" style="background:rgba(27,94,123,0.4)">
                                    <svg class="w-4 h-4" fill="white" viewBox="0 0 24 24"><path d="M8 5v14l11-7z"/></svg>
                                </div>
                                <div class="flex-1">
                                    <div class="text-[8px] font-bold text-white">تمارين الكتف بعد الجراحة</div>
                                    <div class="text-[6px] text-white/40">٢.٤ك مشاهدة • ريلزي الأخير</div>
                                </div>
                            </div>
                        </div>
                        {{-- Bottom nav --}}
                        <div class="phone-nav">
                            @foreach([['🏠','الرئيسية',true],['📅','مواعيد',false],['💬','رسائل',false],['🎬','ريلز',false],['👤','ملفي',false]] as $n)
                                <div class="phone-nav-item {{ $n[2]?'active':'' }}">
                                    <span class="phone-nav-icon">{{ $n[0] }}</span>
                                    <span class="phone-nav-label" style="{{ $n[2]?'color:#D42B24':'' }}">{{ $n[1] }}</span>
                                </div>
                            @endforeach
                        </div>
                    </div>
                </div>
                <div class="text-center mt-3 text-xs text-white/35 font-semibold">تطبيق الأخصائي</div>
            </div>
        </div>
    </div>

    <div class="absolute bottom-8 left-1/2 -translate-x-1/2 flex flex-col items-center gap-2 text-white/25 text-xs animate-bounce">
        <span data-i18n="scrollMore">اكتشف المزيد</span>
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/></svg>
    </div>
</section>

{{-- ════ ABOUT ════ --}}
<section id="about" class="py-20 px-5" style="background:linear-gradient(180deg,#050D1A 0%,#080F1F 100%)">
    <div class="max-w-5xl mx-auto">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-5 fade-up">
            @foreach([
                ['🦴','علاج طبيعي','تأهيل وإعادة تفعيل الحركة بعد الإصابات والعمليات الجراحية ومشاكل العظام والمفاصل.','grad-teal'],
                ['🤲','علاج وظيفي','مساعدة المرضى على استعادة قدراتهم اليومية والعودة للحياة المستقلة الطبيعية.','grad-purple'],
                ['🏃','إعادة التأهيل','برامج تأهيل متخصصة للرياضيين والمرضى بعد السكتة الدماغية وإصابات الأعصاب.','grad-green'],
            ] as $i => $s)
                <div class="glass rounded-2xl p-6 text-center hover:bg-white/6 transition-all hover:-translate-y-1">
                    <div class="w-14 h-14 rounded-2xl {{ $s[3] }} flex items-center justify-center text-3xl mx-auto mb-4">{{ $s[0] }}</div>
                    <h3 class="font-bold text-lg mb-2" data-i18n="about{{ $i+1 }}Title">{{ $s[1] }}</h3>
                    <p class="text-white/50 text-sm leading-relaxed" data-i18n="about{{ $i+1 }}Desc">{{ $s[2] }}</p>
                </div>
            @endforeach
        </div>
    </div>
</section>

{{-- ════ FEATURES ════ --}}
<section id="features" class="py-24 px-5" style="background:#080F1F">
    <div class="max-w-6xl mx-auto">
        <div class="text-center mb-16 fade-up">
            <div class="inline-block bg-[#D42B24]/10 border border-[#D42B24]/20 text-[#D42B24] text-sm font-bold px-4 py-1.5 rounded-full mb-4" data-i18n="featBadge">✨ مميزات المنصة</div>
            <h2 class="text-4xl font-black mb-4" data-i18n="featH2">كل ما تحتاجه في مكان واحد</h2>
            <p class="text-white/50 text-lg max-w-xl mx-auto" data-i18n="featSub">منصة متكاملة تخدم المريض والأخصائي معاً بأعلى معايير الجودة</p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
            @foreach([
                ['📅','حجز سهل وفوري','احجز موعدك في ثوانٍ. اختر وقتك ونوع الجلسة (أونلاين أو حضوري) بضغطة واحدة.','grad-teal'],
                ['🏋️','برامج منزلية','يصف لك أخصائيك تمارين منزلية مخصصة مع صور وفيديوهات توضيحية.','grad-green'],
                ['📊','تتبع تقدمك','أهداف علاجية مع مقياس التقدم. تابع رحلتك من الجلسة الأولى حتى التعافي الكامل.','grad-purple'],
                ['🎬','ريلز تثقيفية','شاهد فيديوهات توعوية من أخصائيين معتمدين حول التمارين والوقاية من الإصابات.','grad-red'],
                ['💬','تواصل مباشر','محادثة مع أخصائيك + مكالمات صوتية ومرئية آمنة في التطبيق.','grad-orange'],
                ['🏆','أخصائيون موثقون','كل أخصائي يمر بمراجعة دقيقة والتحقق من شهاداته وترخيصه. جودة مضمونة.','grad-blue'],
            ] as $i => $f)
                <div class="fade-up glass rounded-2xl p-6 hover:bg-white/6 transition-all hover:-translate-y-1 group">
                    <div class="w-12 h-12 rounded-xl flex items-center justify-center text-2xl mb-4 {{ $f[3] }} group-hover:scale-110 transition-transform">{{ $f[0] }}</div>
                    <h3 class="font-bold text-lg mb-2" data-i18n="feat{{ $i+1 }}Title">{{ $f[1] }}</h3>
                    <p class="text-white/50 text-sm leading-relaxed" data-i18n="feat{{ $i+1 }}Desc">{{ $f[2] }}</p>
                </div>
            @endforeach
        </div>
    </div>
</section>

{{-- ════ HOW IT WORKS ════ --}}
<section class="py-24 px-5" style="background:#050D1A">
    <div class="max-w-5xl mx-auto">
        <div class="text-center mb-16 fade-up">
            <div class="inline-block bg-[#1B5E7B]/15 border border-[#1B5E7B]/25 text-[#5BC4E8] text-sm font-bold px-4 py-1.5 rounded-full mb-4" data-i18n="howBadge">⚡ كيف يعمل؟</div>
            <h2 class="text-4xl font-black mb-4" data-i18n="howH2">ابدأ رحلة التعافي في ٣ خطوات</h2>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 relative">
            <div class="hidden md:block absolute top-10 left-1/4 right-1/4 h-px bg-gradient-to-r from-transparent via-white/15 to-transparent"></div>
            @foreach([
                ['01','حمّل التطبيق','أنشئ حسابك كمريض في أقل من دقيقة. لا حاجة لأي معلومات معقدة.','#D42B24'],
                ['02','اختر أخصائيك','تصفّح قائمة الأخصائيين المعتمدين، اقرأ تقييماتهم، اختر الأنسب لحالتك.','#F59E0B'],
                ['03','ابدأ العلاج','احجز جلستك وتابع برنامجك العلاجي حتى تعافٍ كامل.','#4ADE80'],
            ] as $i => $s)
                <div class="fade-up text-center flex flex-col items-center">
                    <div class="w-20 h-20 rounded-2xl glass flex items-center justify-center text-3xl font-black mb-5"
                         style="color:{{ $s[3] }};border-color:{{ $s[3] }}33;border-width:2px">{{ $s[0] }}</div>
                    <h3 class="font-bold text-xl mb-2" data-i18n="how{{ $i+1 }}Title">{{ $s[1] }}</h3>
                    <p class="text-white/50 text-sm leading-relaxed max-w-xs" data-i18n="how{{ $i+1 }}Desc">{{ $s[2] }}</p>
                </div>
            @endforeach
        </div>
    </div>
</section>

{{-- ════ SCREENS SHOWCASE ════ --}}
<section id="screens" class="py-24 px-5 overflow-hidden" style="background:linear-gradient(180deg,#050D1A 0%,#080F1F 50%,#050D1A 100%)">
    <div class="max-w-6xl mx-auto">
        <div class="text-center mb-16 fade-up">
            <div class="inline-block bg-white/5 border border-white/8 text-white/60 text-sm font-bold px-4 py-1.5 rounded-full mb-4" data-i18n="scrnBadge">📱 شاشات التطبيق الحقيقية</div>
            <h2 class="text-4xl font-black mb-4" data-i18n="scrnH2">تجربة سلسة وسهلة الاستخدام</h2>
            <p class="text-white/45" data-i18n="scrnSub">كل شاشة صُمِّمت بعناية لتوفير أفضل تجربة للمريض والأخصائي</p>
        </div>

        {{-- ── Patient Screens ── --}}
        <div class="mb-20">
            <div class="flex items-center gap-3 mb-8 fade-up">
                <div class="w-8 h-8 rounded-xl grad-red flex items-center justify-center text-sm">👤</div>
                <h3 class="text-xl font-bold" data-i18n="scrnPatient">تطبيق المريض</h3>
                <div class="flex-1 h-px bg-white/8"></div>
            </div>
            <div class="flex gap-5 overflow-x-auto pb-4 snap-x" style="scrollbar-width:none">

                {{-- Screen: Therapist List --}}
                <div class="snap-start flex-shrink-0 fade-up">
                    <div class="phone-frame float3">
                        <div class="phone-screen flex flex-col" style="background:#060E1C">
                            <div class="flex-1 p-3 pt-7 flex flex-col gap-2 overflow-hidden">
                                <div class="text-[10px] font-black text-white">الأخصائيون 🔍</div>
                                {{-- Search --}}
                                <div class="bg-white/6 rounded-xl px-2 py-1.5 flex items-center gap-1.5 border border-white/8">
                                    <svg class="w-3 h-3 text-white/30" fill="none" stroke="currentColor" viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35" stroke-linecap="round"/></svg>
                                    <div class="text-[7px] text-white/30">ابحث عن أخصائي...</div>
                                </div>
                                {{-- Filter chips --}}
                                <div class="flex gap-1.5 overflow-hidden">
                                    @foreach(['الكل','علاج طبيعي','علاج وظيفي','أعصاب'] as $fi=>$f)
                                        <div class="px-2 py-1 rounded-full text-[6px] font-bold flex-shrink-0 {{ $fi===0?'bg-[#D42B24] text-white':'bg-white/6 text-white/50' }}">{{ $f }}</div>
                                    @endforeach
                                </div>
                                {{-- Therapist cards --}}
                                @foreach([
                                    ['د. سارة حداد','أخصائية علاج طبيعي','10 سنوات خبرة','4.9','D42B24','FF7B6B'],
                                    ['د. كريم ناصر','أخصائي علاج وظيفي','7 سنوات خبرة','4.8','1B5E7B','2D9EC4'],
                                    ['د. منى سعيد','أخصائية أعصاب','12 سنة خبرة','4.7','5B3FA6','8B6FD6'],
                                ] as $d)
                                    <div class="bg-white/5 rounded-xl p-2 border border-white/6">
                                        <div class="flex items-center gap-2">
                                            <div class="w-9 h-9 rounded-xl flex-shrink-0 flex items-center justify-center text-[12px] font-black text-white"
                                                 style="background:linear-gradient(135deg,#{{ $d[4] }},#{{ $d[5] }})">{{ mb_substr($d[0],3,1) }}</div>
                                            <div class="flex-1 min-w-0">
                                                <div class="text-[8px] font-black text-white">{{ $d[0] }}</div>
                                                <div class="text-[7px] text-white/45">{{ $d[1] }}</div>
                                                <div class="text-[6px] text-white/30">{{ $d[2] }}</div>
                                            </div>
                                            <div>
                                                <div class="text-[8px] text-yellow-400 font-bold">⭐{{ $d[3] }}</div>
                                                <div class="text-[6px] bg-[#D42B24]/20 text-[#FF7B6B] px-1.5 py-0.5 rounded-full mt-0.5 text-center">احجز</div>
                                            </div>
                                        </div>
                                    </div>
                                @endforeach
                            </div>
                            <div class="phone-nav">
                                @foreach([['🏠','',false],['🔍','',true],['📅','',false],['💬','',false],['👤','',false]] as $n)
                                    <div class="phone-nav-item"><span class="phone-nav-icon">{{ $n[0] }}</span></div>
                                @endforeach
                            </div>
                        </div>
                    </div>
                    <p class="text-center text-xs text-white/35 mt-2 font-semibold" data-i18n="scrn1">قائمة الأخصائيين</p>
                </div>

                {{-- Screen: Therapist Detail --}}
                <div class="snap-start flex-shrink-0 fade-up" style="transition-delay:.1s">
                    <div class="phone-frame float2">
                        <div class="phone-screen flex flex-col" style="background:#060E1C">
                            <div class="flex-1 flex flex-col overflow-hidden">
                                {{-- Hero --}}
                                <div class="h-28 flex-shrink-0 flex flex-col items-center justify-end pb-2"
                                     style="background:linear-gradient(175deg,#0B1E36,#1B5E7B)">
                                    <div class="w-12 h-12 rounded-2xl flex items-center justify-center text-xl font-black text-white mb-1"
                                         style="background:rgba(255,255,255,0.15)">س</div>
                                    <div class="text-[10px] font-black text-white">د. سارة حداد</div>
                                    <div class="text-[7px] text-white/60">أخصائية علاج طبيعي</div>
                                </div>
                                <div class="p-3 flex flex-col gap-2">
                                    {{-- Rating & stars --}}
                                    <div class="flex justify-center gap-0.5">
                                        @for($i=0;$i<5;$i++)<span class="text-yellow-400 text-[10px]">★</span>@endfor
                                        <span class="text-[7px] text-white/40 mr-1">٤.٩ (٨٧ تقييم)</span>
                                    </div>
                                    {{-- Badges --}}
                                    <div class="flex justify-center gap-1.5 flex-wrap">
                                        <span class="text-[6px] badge-online px-2 py-0.5 rounded-full">🌐 أونلاين</span>
                                        <span class="text-[6px] badge-inperson px-2 py-0.5 rounded-full">🏥 حضوري</span>
                                        <span class="text-[6px] badge-confirmed px-2 py-0.5 rounded-full">✓ موثقة</span>
                                    </div>
                                    {{-- Stats --}}
                                    <div class="grid grid-cols-3 gap-1">
                                        @foreach([['10+','خبرة'],['₪200','حضوري'],['₪150','أونلاين']] as $st)
                                            <div class="bg-white/5 rounded-xl p-1.5 text-center border border-white/6">
                                                <div class="text-[10px] font-black text-white">{{ $st[0] }}</div>
                                                <div class="text-[6px] text-white/40">{{ $st[1] }}</div>
                                            </div>
                                        @endforeach
                                    </div>
                                    {{-- Bio preview --}}
                                    <div class="text-[7px] text-white/45 leading-relaxed">أخصائية علاج طبيعي معتمدة متخصصة في إصابات الركبة والعمود الفقري...</div>
                                    {{-- Book button --}}
                                    <div class="bg-[#D42B24] rounded-xl py-2 text-center text-[10px] font-black mt-1">احجز جلسة</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <p class="text-center text-xs text-white/35 mt-2 font-semibold" data-i18n="scrn2">ملف الأخصائي</p>
                </div>

                {{-- Screen: Booking --}}
                <div class="snap-start flex-shrink-0 fade-up" style="transition-delay:.2s">
                    <div class="phone-frame float">
                        <div class="phone-screen flex flex-col" style="background:#060E1C">
                            <div class="flex-1 p-3 pt-7 flex flex-col gap-2 overflow-hidden">
                                <div class="text-[10px] font-black text-white">احجز موعدك 📅</div>
                                {{-- Session type --}}
                                <div class="text-[7px] text-white/50 font-semibold">نوع الجلسة</div>
                                <div class="grid grid-cols-2 gap-1.5">
                                    <div class="bg-[#1B5E7B]/25 border border-[#1B5E7B]/60 rounded-xl p-2 text-center">
                                        <div class="text-sm">🌐</div>
                                        <div class="text-[8px] font-bold text-white">أونلاين</div>
                                        <div class="text-[7px] text-[#5BC4E8]">₪150</div>
                                    </div>
                                    <div class="bg-white/4 rounded-xl p-2 text-center border border-white/6">
                                        <div class="text-sm">🏥</div>
                                        <div class="text-[8px] font-bold text-white">حضوري</div>
                                        <div class="text-[7px] text-white/35">₪200</div>
                                    </div>
                                </div>
                                {{-- Days --}}
                                <div class="text-[7px] text-white/50 font-semibold">اختر اليوم</div>
                                <div class="flex gap-1 overflow-hidden">
                                    @foreach(['الأح','الإث','الثل','الأر','الخم'] as $di=>$d)
                                        <div class="flex-1 rounded-xl py-1.5 text-center {{ $di===2?'bg-[#D42B24]':'bg-white/5' }}">
                                            <div class="text-[5px] text-white/50">{{ $d }}</div>
                                            <div class="text-[9px] font-bold text-white">{{ 10+$di }}</div>
                                        </div>
                                    @endforeach
                                </div>
                                {{-- Time slots --}}
                                <div class="text-[7px] text-white/50 font-semibold">الأوقات المتاحة</div>
                                <div class="grid grid-cols-3 gap-1">
                                    @foreach(['٩:٠٠','١٠:٠٠','١١:٠٠','١:٠٠','٢:٠٠','٤:٠٠'] as $ti=>$t)
                                        <div class="rounded-lg py-1.5 text-center text-[7px] {{ $ti===1?'bg-[#D42B24] font-bold':'bg-white/5 text-white/55 border border-white/6' }}">{{ $t }}</div>
                                    @endforeach
                                </div>
                                <div class="mt-auto bg-[#D42B24] rounded-xl py-2 text-center text-[9px] font-black">تأكيد الحجز ✓</div>
                            </div>
                        </div>
                    </div>
                    <p class="text-center text-xs text-white/35 mt-2 font-semibold" data-i18n="scrn3">حجز الموعد</p>
                </div>

                {{-- Screen: Chat --}}
                <div class="snap-start flex-shrink-0 fade-up" style="transition-delay:.3s">
                    <div class="phone-frame float3">
                        <div class="phone-screen flex flex-col" style="background:#060E1C">
                            <div class="flex-1 flex flex-col overflow-hidden">
                                {{-- Chat header --}}
                                <div class="p-3 pt-7 pb-2 border-b border-white/8 flex items-center gap-2 flex-shrink-0">
                                    <div class="w-8 h-8 rounded-xl flex items-center justify-center text-[10px] font-black text-white"
                                         style="background:linear-gradient(135deg,#1B5E7B,#2D9EC4)">س</div>
                                    <div>
                                        <div class="text-[9px] font-black text-white">د. سارة حداد</div>
                                        <div class="text-[6px] text-green-400">● متصلة الآن</div>
                                    </div>
                                    <div class="mr-auto flex gap-2">
                                        <svg class="w-4 h-4 text-white/40" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"/></svg>
                                        <svg class="w-4 h-4 text-white/40" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.069A1 1 0 0121 8.867v6.266a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"/></svg>
                                    </div>
                                </div>
                                {{-- Messages --}}
                                <div class="flex-1 p-3 flex flex-col justify-end gap-1.5 overflow-hidden">
                                    <div class="self-start max-w-[82%] bg-white/8 rounded-xl rounded-tl-sm px-2 py-1.5">
                                        <div class="text-[7px] text-white leading-relaxed">كيف حال الركبة؟ هل جربت تمرين التمديد؟</div>
                                        <div class="text-[5px] text-white/25 mt-0.5">١٠:٠٢ ص</div>
                                    </div>
                                    <div class="self-end max-w-[82%] bg-[#D42B24]/75 rounded-xl rounded-tr-sm px-2 py-1.5">
                                        <div class="text-[7px] text-white leading-relaxed">نعم، أحسست بتحسن ملحوظ 🙏</div>
                                        <div class="text-[5px] text-white/40 mt-0.5 text-left">١٠:٠٥ ✓✓</div>
                                    </div>
                                    <div class="self-start max-w-[82%] bg-white/8 rounded-xl rounded-tl-sm px-2 py-1.5">
                                        <div class="text-[7px] text-white leading-relaxed">ممتاز! كرر التمرين ١٥ مرة مرتين يومياً</div>
                                        <div class="text-[5px] text-white/25 mt-0.5">١٠:٠٧ ص</div>
                                    </div>
                                </div>
                                {{-- Input --}}
                                <div class="p-2 border-t border-white/8 flex items-center gap-1.5 flex-shrink-0">
                                    <div class="flex-1 bg-white/6 rounded-xl px-2 py-1.5 text-[7px] text-white/25 border border-white/8">اكتب رسالة...</div>
                                    <div class="w-7 h-7 bg-[#D42B24] rounded-xl flex items-center justify-center flex-shrink-0">
                                        <svg class="w-3 h-3 rotate-180" fill="white" viewBox="0 0 24 24"><path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"/></svg>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <p class="text-center text-xs text-white/35 mt-2 font-semibold" data-i18n="scrn4">المحادثة</p>
                </div>

                {{-- Screen: Home Programs --}}
                <div class="snap-start flex-shrink-0 fade-up" style="transition-delay:.4s">
                    <div class="phone-frame float2">
                        <div class="phone-screen flex flex-col" style="background:#060E1C">
                            <div class="flex-1 p-3 pt-7 flex flex-col gap-2 overflow-hidden">
                                <div class="text-[10px] font-black text-white">برامجي 🏋️</div>
                                <div class="text-[7px] text-white/40">برنامج تأهيل الركبة • اليوم ٥/٢١</div>
                                {{-- Progress --}}
                                <div class="bg-white/5 rounded-xl p-2.5 border border-white/8">
                                    <div class="flex justify-between mb-1.5">
                                        <span class="text-[7px] text-white/60">التقدم الكلي</span>
                                        <span class="text-[7px] font-bold" style="color:#4ADE80">٢٤٪</span>
                                    </div>
                                    <div class="w-full h-1.5 bg-white/10 rounded-full overflow-hidden">
                                        <div class="h-full rounded-full" style="width:24%;background:linear-gradient(90deg,#4ADE80,#22D3EE)"></div>
                                    </div>
                                </div>
                                {{-- Exercises --}}
                                <div class="text-[7px] text-white/50 font-semibold">تمارين اليوم</div>
                                @foreach([
                                    ['تمديد عضلة الفخذ الأمامية','٣ مجموعات × ١٥','✅'],
                                    ['ثني الركبة جالساً','٣ × ٢٠','✅'],
                                    ['رفع الساق مستقيمة','٢ × ١٠','⬜'],
                                    ['المشي على الكعب','٥ دقائق','⬜'],
                                ] as $ex)
                                    <div class="bg-white/5 rounded-lg px-2 py-1.5 flex items-center gap-2 border border-white/6">
                                        <span class="text-[10px]">{{ $ex[2] }}</span>
                                        <div class="flex-1">
                                            <div class="text-[7px] font-bold text-white leading-tight">{{ $ex[0] }}</div>
                                            <div class="text-[6px] text-white/35">{{ $ex[1] }}</div>
                                        </div>
                                    </div>
                                @endforeach
                            </div>
                            <div class="phone-nav">
                                @foreach(['🏠','🔍','📅','💬','👤'] as $i)
                                    <div class="phone-nav-item"><span class="phone-nav-icon">{{ $i }}</span></div>
                                @endforeach
                            </div>
                        </div>
                    </div>
                    <p class="text-center text-xs text-white/35 mt-2 font-semibold" data-i18n="scrn5">البرامج المنزلية</p>
                </div>
            </div>
        </div>

        {{-- ── Therapist Screens ── --}}
        <div>
            <div class="flex items-center gap-3 mb-8 fade-up">
                <div class="w-8 h-8 rounded-xl grad-teal flex items-center justify-center text-sm">⚕️</div>
                <h3 class="text-xl font-bold" data-i18n="scrnTherapist">تطبيق الأخصائي</h3>
                <div class="flex-1 h-px bg-white/8"></div>
            </div>
            <div class="flex gap-5 overflow-x-auto pb-4 snap-x" style="scrollbar-width:none">

                {{-- Therapist: Dashboard --}}
                <div class="snap-start flex-shrink-0 fade-up">
                    <div class="phone-frame float2">
                        <div class="phone-screen flex flex-col" style="background:linear-gradient(175deg,#060E1C,#0B1E36)">
                            <div class="flex-1 p-3 pt-7 flex flex-col gap-2 overflow-hidden">
                                <div class="flex items-center justify-between">
                                    <div>
                                        <div class="text-[8px] text-white/40">لوحة الأخصائي</div>
                                        <div class="text-[11px] font-black text-white">د. أميرة سالم 🏥</div>
                                    </div>
                                    <div class="w-6 h-6 rounded-full" style="background:linear-gradient(135deg,#1B5E7B,#38BDF8)"></div>
                                </div>
                                <div class="grid grid-cols-2 gap-1.5">
                                    @foreach([['٩','مواعيد اليوم','#D42B24'],['₪٢٤٠٠','أرباح الأسبوع','#4ADE80']] as $s)
                                        <div class="rounded-xl p-2.5" style="background:{{ $s[2] }}18;border:1px solid {{ $s[2] }}28">
                                            <div class="text-[14px] font-black" style="color:{{ $s[2] }}">{{ $s[0] }}</div>
                                            <div class="text-[6px] text-white/40">{{ $s[1] }}</div>
                                        </div>
                                    @endforeach
                                </div>
                                <div class="text-[8px] text-white/60 font-bold">أقرب المواعيد</div>
                                @foreach([
                                    ['أحمد محمد','٩:٠٠ ص','أونلاين'],
                                    ['ليلى خالد','١١:٠٠ ص','حضوري'],
                                    ['سامر علي','٢:٠٠ م','أونلاين'],
                                ] as $a)
                                    <div class="bg-white/5 rounded-xl p-2 flex items-center justify-between border border-white/6">
                                        <div class="flex items-center gap-1.5">
                                            <div class="w-7 h-7 rounded-lg flex items-center justify-center text-[9px] font-black text-white"
                                                 style="background:rgba(27,94,123,0.4)">{{ mb_substr($a[0],0,1) }}</div>
                                            <div>
                                                <div class="text-[8px] font-bold text-white">{{ $a[0] }}</div>
                                                <div class="text-[6px] text-white/35">{{ $a[1] }} • {{ $a[2] }}</div>
                                            </div>
                                        </div>
                                        <div class="w-6 h-6 rounded-lg flex items-center justify-center" style="background:rgba(27,94,123,0.3)">
                                            <svg class="w-3 h-3" fill="white" viewBox="0 0 24 24"><path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2z"/></svg>
                                        </div>
                                    </div>
                                @endforeach
                            </div>
                            <div class="phone-nav">
                                @foreach([['🏠','',true],['📅','',false],['💬','',false],['🎬','',false],['👤','',false]] as $n)
                                    <div class="phone-nav-item {{ $n[2]?'active':'' }}"><span class="phone-nav-icon">{{ $n[0] }}</span></div>
                                @endforeach
                            </div>
                        </div>
                    </div>
                    <p class="text-center text-xs text-white/35 mt-2 font-semibold" data-i18n="scrn6">اللوحة الرئيسية</p>
                </div>

                {{-- Therapist: Schedule --}}
                <div class="snap-start flex-shrink-0 fade-up" style="transition-delay:.1s">
                    <div class="phone-frame float">
                        <div class="phone-screen flex flex-col" style="background:#060E1C">
                            <div class="flex-1 p-3 pt-7 flex flex-col gap-2 overflow-hidden">
                                <div class="text-[10px] font-black text-white">جدول الدوام 📆</div>
                                {{-- Days --}}
                                <div class="flex gap-1">
                                    @foreach(['الأح','الإث','الثل','الأر','الخم','الجم'] as $di=>$d)
                                        <div class="flex-1 rounded-lg py-1 text-center {{ $di===2?'bg-[#1B5E7B]':'bg-white/4' }}">
                                            <div class="text-[5px] text-white/40">{{ $d }}</div>
                                        </div>
                                    @endforeach
                                </div>
                                {{-- Slots --}}
                                @foreach([
                                    ['٩:٠٠ ص','أحمد محمد','أونلاين',true],
                                    ['١٠:٣٠ ص','ليلى خالد','حضوري',true],
                                    ['١٢:٠٠ م','متاح','',false],
                                    ['٢:٠٠ م','سامر علي','أونلاين',true],
                                    ['٣:٣٠ م','متاح','',false],
                                ] as $slot)
                                    <div class="flex items-center gap-2 {{ $slot[3]?'bg-[#1B5E7B]/15 border border-[#1B5E7B]/25':'bg-white/3 border border-white/5' }} rounded-xl p-2">
                                        <div class="text-[6px] text-white/40 w-10 flex-shrink-0">{{ $slot[0] }}</div>
                                        <div class="flex-1 min-w-0">
                                            <div class="text-[7px] font-bold truncate {{ !$slot[3]?'text-white/25':'text-white' }}">{{ $slot[1] }}</div>
                                            @if($slot[2])
                                                <div class="text-[6px] text-white/35">{{ $slot[2] }}</div>
                                            @endif
                                        </div>
                                        @if($slot[3])
                                            <div class="w-4 h-4 rounded-full bg-green-500/20 flex items-center justify-center">
                                                <div class="w-1.5 h-1.5 rounded-full bg-green-400"></div>
                                            </div>
                                        @endif
                                    </div>
                                @endforeach
                            </div>
                            <div class="phone-nav">
                                @foreach([['🏠','',false],['📅','',true],['💬','',false],['🎬','',false],['👤','',false]] as $n)
                                    <div class="phone-nav-item {{ $n[2]?'active':'' }}"><span class="phone-nav-icon">{{ $n[0] }}</span></div>
                                @endforeach
                            </div>
                        </div>
                    </div>
                    <p class="text-center text-xs text-white/35 mt-2 font-semibold" data-i18n="scrn7">جدول الدوام</p>
                </div>

                {{-- Therapist: Reels --}}
                <div class="snap-start flex-shrink-0 fade-up" style="transition-delay:.2s">
                    <div class="phone-frame float3">
                        <div class="phone-screen flex flex-col" style="background:#060E1C">
                            <div class="flex-1 pt-7 flex flex-col overflow-hidden">
                                <div class="px-3 pb-2 flex items-center justify-between">
                                    <div class="text-[10px] font-black text-white">ريلزي 🎬</div>
                                    <div class="text-[7px] bg-[#D42B24] px-2 py-0.5 rounded-full">+ ريلز جديد</div>
                                </div>
                                <div class="grid grid-cols-2 gap-0.5 flex-1 overflow-hidden">
                                    @foreach([
                                        ['#D42B24','#FF7B6B','تمارين الكتف بعد الجراحة','٣.٢ك'],
                                        ['#1B5E7B','#2D9EC4','إعادة تأهيل الركبة','٢.١ك'],
                                        ['#5B3FA6','#8B6FD6','تمارين الظهر السليمة','١.٨ك'],
                                        ['#064E3B','#065F46','علاج آلام العنق','٩٠٠'],
                                    ] as $r)
                                        <div class="relative overflow-hidden"
                                             style="background:linear-gradient(135deg,{{ $r[0] }},{{ $r[1] }})">
                                            <div class="absolute inset-0 flex items-center justify-center">
                                                <div class="w-7 h-7 bg-black/30 rounded-full flex items-center justify-center">
                                                    <svg class="w-3.5 h-3.5" fill="white" viewBox="0 0 24 24"><path d="M8 5v14l11-7z"/></svg>
                                                </div>
                                            </div>
                                            <div class="absolute bottom-1 right-1 left-1">
                                                <div class="text-[5px] text-white/80 font-bold leading-tight">{{ $r[2] }}</div>
                                                <div class="text-[5px] text-white/50">❤️ {{ $r[3] }}</div>
                                            </div>
                                        </div>
                                    @endforeach
                                </div>
                            </div>
                            <div class="phone-nav">
                                @foreach([['🏠','',false],['📅','',false],['💬','',false],['🎬','',true],['👤','',false]] as $n)
                                    <div class="phone-nav-item {{ $n[2]?'active':'' }}"><span class="phone-nav-icon">{{ $n[0] }}</span></div>
                                @endforeach
                            </div>
                        </div>
                    </div>
                    <p class="text-center text-xs text-white/35 mt-2 font-semibold" data-i18n="scrn8">الريلز التثقيفية</p>
                </div>

                {{-- Therapist: Goals --}}
                <div class="snap-start flex-shrink-0 fade-up" style="transition-delay:.3s">
                    <div class="phone-frame float2">
                        <div class="phone-screen flex flex-col" style="background:#060E1C">
                            <div class="flex-1 p-3 pt-7 flex flex-col gap-2 overflow-hidden">
                                <div class="text-[10px] font-black text-white">الأهداف العلاجية 🎯</div>
                                <div class="text-[7px] text-white/40">أحمد محمد — تأهيل الركبة</div>
                                @foreach([
                                    ['العودة للمشي بدون ألم','٧٠','#4ADE80'],
                                    ['زيادة مدى الحركة ٩٠°','٤٥','#F59E0B'],
                                    ['تقوية عضلات الفخذ','٣٠','#38BDF8'],
                                ] as $g)
                                    <div class="bg-white/5 rounded-xl p-2.5 border border-white/6">
                                        <div class="flex items-center justify-between mb-1.5">
                                            <span class="text-[7px] font-bold text-white">{{ $g[0] }}</span>
                                            <span class="text-[7px] font-black" style="color:{{ $g[2] }}">{{ $g[1] }}٪</span>
                                        </div>
                                        <div class="w-full h-1.5 bg-white/8 rounded-full overflow-hidden">
                                            <div class="h-full rounded-full" style="width:{{ $g[1] }}%;background:{{ $g[2] }}"></div>
                                        </div>
                                    </div>
                                @endforeach
                                <div class="mt-auto bg-[#D42B24]/15 border border-[#D42B24]/25 rounded-xl p-2 text-center">
                                    <div class="text-[8px] font-bold text-white">+ إضافة هدف جديد</div>
                                </div>
                            </div>
                            <div class="phone-nav">
                                @foreach(['🏠','📅','💬','🎬','👤'] as $i)
                                    <div class="phone-nav-item"><span class="phone-nav-icon">{{ $i }}</span></div>
                                @endforeach
                            </div>
                        </div>
                    </div>
                    <p class="text-center text-xs text-white/35 mt-2 font-semibold" data-i18n="scrn9">الأهداف العلاجية</p>
                </div>
            </div>
        </div>
    </div>
</section>

{{-- ════ CTA ════ --}}
<section class="py-20 px-5" style="background:#080F1F">
    <div class="max-w-5xl mx-auto">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            {{-- Patient CTA --}}
            <div class="fade-up glass rounded-3xl p-8 relative overflow-hidden">
                <div class="absolute top-0 right-0 w-40 h-40 rounded-full opacity-10"
                     style="background:radial-gradient(circle,#D42B24,transparent);filter:blur(30px)"></div>
                <div class="text-4xl mb-4">🏃</div>
                <h3 class="text-2xl font-black mb-3" data-i18n="ctaPatientH">تعاني من ألم أو إصابة؟</h3>
                <p class="text-white/50 text-sm leading-relaxed mb-6" data-i18n="ctaPatientDesc">
                    احصل على رعاية متخصصة من أفضل أخصائيي العلاج الطبيعي والوظيفي في فلسطين.
                    ابدأ رحلة تعافيك اليوم من المنزل أو حضورياً.
                </p>
                <a href="#download"
                   class="inline-flex items-center gap-2 bg-[#D42B24] hover:bg-[#b82220] text-white font-bold px-6 py-3 rounded-xl text-sm transition-all glow-red">
                    <span data-i18n="ctaPatientBtn">حمّل تطبيق المريض</span>
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8l4 4m0 0l-4 4m4-4H3"/></svg>
                </a>
            </div>
            {{-- Therapist CTA --}}
            <div class="fade-up glass rounded-3xl p-8 relative overflow-hidden" style="transition-delay:.15s">
                <div class="absolute top-0 left-0 w-40 h-40 rounded-full opacity-10"
                     style="background:radial-gradient(circle,#1B5E7B,transparent);filter:blur(30px)"></div>
                <div class="text-4xl mb-4">⚕️</div>
                <h3 class="text-2xl font-black mb-3" data-i18n="ctaTherapistH">أنت أخصائي علاج؟</h3>
                <p class="text-white/50 text-sm leading-relaxed mb-6" data-i18n="ctaTherapistDesc">
                    وسّع نطاق عملك ووصل لمرضى أكثر. أنشئ ملفك المهني، ارفع شهاداتك،
                    وابدأ بإدارة مواعيدك ومتابعة مرضاك بشكل احترافي.
                </p>
                <a href="#download"
                   class="inline-flex items-center gap-2 text-white font-bold px-6 py-3 rounded-xl text-sm transition-all glow-blue"
                   style="background:linear-gradient(135deg,#1B5E7B,#0F2E5A)">
                    <span data-i18n="ctaTherapistBtn">حمّل تطبيق الأخصائي</span>
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8l4 4m0 0l-4 4m4-4H3"/></svg>
                </a>
            </div>
        </div>
    </div>
</section>

{{-- ════ DOWNLOAD ════ --}}
<section id="download" class="py-24 px-5 grad-hero relative overflow-hidden">
    <div class="absolute inset-0 opacity-15"
         style="background:radial-gradient(ellipse 60% 60% at 50% 50%, #1B5E7B, transparent)"></div>
    <div class="max-w-3xl mx-auto text-center relative fade-up">
        <svg viewBox="0 0 300 40" class="w-56 mx-auto mb-6" fill="none">
            <line x1="0" y1="20" x2="60" y2="20" stroke="#D42B24" stroke-width="2.5" stroke-linecap="round"/>
            <polyline points="60,20 85,4 95,36 110,5 122,26 135,20 300,20"
                      stroke="#D42B24" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"
                      class="hb-line" fill="none"/>
        </svg>

        <h2 class="text-5xl font-black mb-4" data-i18n="dlH2">حمّل <span class="grad-text-red">نبض</span> الآن</h2>
        <p class="text-white/50 text-lg mb-10 max-w-lg mx-auto" data-i18n="dlPara">
            متاح مجاناً على أندرويد. ابدأ رحلتك نحو التعافي الكامل اليوم.
        </p>

        <div class="flex flex-col sm:flex-row gap-4 justify-center">
            <a href="#" class="flex items-center gap-4 bg-white/8 hover:bg-white/12 border border-white/12 backdrop-blur px-6 py-4 rounded-2xl transition-all hover:scale-105 hover:-translate-y-1">
                <svg class="w-9 h-9 flex-shrink-0" fill="currentColor" viewBox="0 0 24 24"><path d="M3.18 23.76c.33.18.7.24 1.06.18L14.93 12 4.24.06C3.88 0 3.51.06 3.18.24 2.49.62 2.07 1.34 2.07 2.15v19.7c0 .81.42 1.53 1.11 1.91zM16.54 13.61l2.93 2.93-8.9 5.01 5.97-7.94zm3.89-2.18c.39.22.63.62.63 1.07s-.24.85-.63 1.07l-2.04 1.15-3.24-3.24 3.24-3.24 2.04 1.19zM11.57 7.45L5.6 2.44l8.87 5.01-2.9 2z"/></svg>
                <div class="text-right">
                    <div class="text-xs text-white/45" data-i18n="dlFrom">تحميل من</div>
                    <div class="font-black text-lg" data-i18n="dlPatientLabel">تطبيق المريض</div>
                    <div class="text-xs text-white/35">NABD CARE</div>
                </div>
            </a>
            <a href="#" class="flex items-center gap-4 bg-[#D42B24]/12 hover:bg-[#D42B24]/20 border border-[#D42B24]/25 backdrop-blur px-6 py-4 rounded-2xl transition-all hover:scale-105 hover:-translate-y-1">
                <svg class="w-9 h-9 flex-shrink-0 text-[#D42B24]" fill="currentColor" viewBox="0 0 24 24"><path d="M3.18 23.76c.33.18.7.24 1.06.18L14.93 12 4.24.06C3.88 0 3.51.06 3.18.24 2.49.62 2.07 1.34 2.07 2.15v19.7c0 .81.42 1.53 1.11 1.91zM16.54 13.61l2.93 2.93-8.9 5.01 5.97-7.94zm3.89-2.18c.39.22.63.62.63 1.07s-.24.85-.63 1.07l-2.04 1.15-3.24-3.24 3.24-3.24 2.04 1.19zM11.57 7.45L5.6 2.44l8.87 5.01-2.9 2z"/></svg>
                <div class="text-right">
                    <div class="text-xs text-white/45" data-i18n="dlFrom2">تحميل من</div>
                    <div class="font-black text-lg" data-i18n="dlTherapistLabel">تطبيق الأخصائي</div>
                    <div class="text-xs text-white/35">NABD CARE</div>
                </div>
            </a>
        </div>
        <p class="text-white/20 text-xs mt-8" data-i18n="dlFootnote">يتطلب أندرويد 8.0 أو أحدث</p>
    </div>
</section>

{{-- ════ FOOTER ════ --}}
<footer style="background:#030710;border-top:1px solid rgba(255,255,255,0.05)">
    <div class="max-w-6xl mx-auto px-5 py-12">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-8">
            <div class="md:col-span-2">
                <div class="flex items-center gap-2 mb-4">
                    <svg viewBox="0 0 100 20" class="h-5 w-[68px]" fill="none">
                        <polyline points="0,10 25,10 35,1 42,19 50,4 57,14 63,10 100,10"
                                  stroke="#D42B24" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                    <div class="font-black tracking-widest leading-none select-none">
                        <div class="text-white" style="font-size:14px;line-height:1.05">NABD</div>
                        <div style="color:#D42B24;font-size:14px;line-height:1.05">CARE</div>
                    </div>
                    <svg viewBox="0 0 40 50" class="h-8 w-6 opacity-80" fill="none">
                        <circle cx="22" cy="5" r="5" fill="#9CA3AF"/>
                        <path d="M22 11 L19 27 L34 27 L34 33 L19.5 33" stroke="#9CA3AF" stroke-width="2.4" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
                        <path d="M28.5 49.5 A14 14 0 1 1 28.5 34" stroke="#1B5E7B" stroke-width="2.6" fill="none" stroke-linecap="round"/>
                        <circle cx="33" cy="44" r="3.6" stroke="#1B5E7B" stroke-width="2.2" fill="none"/>
                    </svg>
                </div>
                <p class="text-white/35 text-sm leading-relaxed mb-4 max-w-xs" data-i18n="footerDesc">
                    منصة العلاج الطبيعي والوظيفي الأولى في فلسطين. نربطك بالأخصائي المناسب لتعافٍ أسرع وأفضل.
                </p>
                <div class="flex gap-3">
                    <div class="w-8 h-8 glass rounded-lg flex items-center justify-center hover:bg-white/8 cursor-pointer transition-colors">
                        <svg class="w-4 h-4 text-white/50" fill="currentColor" viewBox="0 0 24 24"><path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/></svg>
                    </div>
                    <div class="w-8 h-8 glass rounded-lg flex items-center justify-center hover:bg-white/8 cursor-pointer transition-colors">
                        <svg class="w-4 h-4 text-white/50" fill="currentColor" viewBox="0 0 24 24"><path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zM12 0C8.741 0 8.333.014 7.053.072 2.695.272.273 2.69.073 7.052.014 8.333 0 8.741 0 12c0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98C8.333 23.986 8.741 24 12 24c3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98C15.668.014 15.259 0 12 0zm0 5.838a6.162 6.162 0 100 12.324 6.162 6.162 0 000-12.324zM12 16a4 4 0 110-8 4 4 0 010 8zm6.406-11.845a1.44 1.44 0 100 2.881 1.44 1.44 0 000-2.881z"/></svg>
                    </div>
                </div>
            </div>
            <div>
                <h4 class="font-bold text-sm mb-4 text-white/70" data-i18n="footerLinks">روابط سريعة</h4>
                <div class="space-y-2">
                    <a href="#about"    class="block text-sm text-white/35 hover:text-white/65 transition-colors" data-i18n="navAbout">عن المنصة</a>
                    <a href="#features" class="block text-sm text-white/35 hover:text-white/65 transition-colors" data-i18n="navFeatures">المميزات</a>
                    <a href="#screens"  class="block text-sm text-white/35 hover:text-white/65 transition-colors" data-i18n="navScreens">الشاشات</a>
                    <a href="#download" class="block text-sm text-white/35 hover:text-white/65 transition-colors" data-i18n="navDownload">تحميل</a>
                </div>
            </div>
            <div>
                <h4 class="font-bold text-sm mb-4 text-white/70" data-i18n="footerLegal">قانوني</h4>
                <div class="space-y-2">
                    <a href="#" class="block text-sm text-white/35 hover:text-white/65 transition-colors" data-i18n="footerTerms">شروط الاستخدام</a>
                    <a href="#" class="block text-sm text-white/35 hover:text-white/65 transition-colors" data-i18n="footerPrivacy">سياسة الخصوصية</a>
                    <a href="/admin" class="block text-sm text-white/35 hover:text-white/65 transition-colors" data-i18n="navAdmin">لوحة الإدارة</a>
                </div>
            </div>
        </div>
        <div class="border-t border-white/5 mt-10 pt-6 flex flex-col md:flex-row items-center justify-between gap-4">
            <p class="text-white/15 text-xs"><span data-i18n="footerCopy">© {{ date('Y') }} نبض — NABD CARE. جميع الحقوق محفوظة.</span></p>
            <p class="text-white/15 text-xs" data-i18n="footerMade">🇵🇸 صُنع في فلسطين بـ ❤️</p>
        </div>
    </div>
</footer>

<script>
    const obs = new IntersectionObserver((entries) => {
        entries.forEach(e => {
            if (e.isIntersecting) { e.target.classList.add('visible'); obs.unobserve(e.target); }
        });
    }, { threshold: 0.08 });
    document.querySelectorAll('.fade-up').forEach(el => obs.observe(el));

    // ════ Multilingual (AR / HE / EN) ════
    const YEAR = '{{ date('Y') }}';
    const I18N = {
        ar: {
            _title: 'نبض — منصة العلاج الطبيعي والوظيفي في فلسطين',
            navAbout: 'عن المنصة', navFeatures: 'المميزات', navScreens: 'الشاشات', navDownload: 'تحميل',
            navAdmin: 'لوحة الإدارة', navAdminShort: 'الإدارة',
            heroBadge: 'المنصة الأولى للعلاج الطبيعي والوظيفي في فلسطين',
            heroH1: 'طريقك نحو<br><span class="grad-text-red">التعافي الكامل</span>',
            heroPara: 'نبض يربطك بأفضل أخصائيي العلاج الطبيعي والوظيفي المعتمدين في فلسطين. احجز جلستك أونلاين أو حضورياً واتابع تقدمك مع كل جلسة.',
            heroCtaAndroid: 'تحميل للأندرويد', heroCtaWatch: 'شاهد كيف يعمل',
            heroStat1: 'أخصائي معتمد', heroStat2: 'جلسة مكتملة', heroStat3: 'تقييم المستخدمين',
            scrollMore: 'اكتشف المزيد',
            about1Title: 'علاج طبيعي', about1Desc: 'تأهيل وإعادة تفعيل الحركة بعد الإصابات والعمليات الجراحية ومشاكل العظام والمفاصل.',
            about2Title: 'علاج وظيفي', about2Desc: 'مساعدة المرضى على استعادة قدراتهم اليومية والعودة للحياة المستقلة الطبيعية.',
            about3Title: 'إعادة التأهيل', about3Desc: 'برامج تأهيل متخصصة للرياضيين والمرضى بعد السكتة الدماغية وإصابات الأعصاب.',
            featBadge: '✨ مميزات المنصة', featH2: 'كل ما تحتاجه في مكان واحد',
            featSub: 'منصة متكاملة تخدم المريض والأخصائي معاً بأعلى معايير الجودة',
            feat1Title: 'حجز سهل وفوري', feat1Desc: 'احجز موعدك في ثوانٍ. اختر وقتك ونوع الجلسة (أونلاين أو حضوري) بضغطة واحدة.',
            feat2Title: 'برامج منزلية', feat2Desc: 'يصف لك أخصائيك تمارين منزلية مخصصة مع صور وفيديوهات توضيحية.',
            feat3Title: 'تتبع تقدمك', feat3Desc: 'أهداف علاجية مع مقياس التقدم. تابع رحلتك من الجلسة الأولى حتى التعافي الكامل.',
            feat4Title: 'ريلز تثقيفية', feat4Desc: 'شاهد فيديوهات توعوية من أخصائيين معتمدين حول التمارين والوقاية من الإصابات.',
            feat5Title: 'تواصل مباشر', feat5Desc: 'محادثة مع أخصائيك + مكالمات صوتية ومرئية آمنة في التطبيق.',
            feat6Title: 'أخصائيون موثقون', feat6Desc: 'كل أخصائي يمر بمراجعة دقيقة والتحقق من شهاداته وترخيصه. جودة مضمونة.',
            howBadge: '⚡ كيف يعمل؟', howH2: 'ابدأ رحلة التعافي في ٣ خطوات',
            how1Title: 'حمّل التطبيق', how1Desc: 'أنشئ حسابك كمريض في أقل من دقيقة. لا حاجة لأي معلومات معقدة.',
            how2Title: 'اختر أخصائيك', how2Desc: 'تصفّح قائمة الأخصائيين المعتمدين، اقرأ تقييماتهم، اختر الأنسب لحالتك.',
            how3Title: 'ابدأ العلاج', how3Desc: 'احجز جلستك وتابع برنامجك العلاجي حتى تعافٍ كامل.',
            scrnBadge: '📱 شاشات التطبيق الحقيقية', scrnH2: 'تجربة سلسة وسهلة الاستخدام',
            scrnSub: 'كل شاشة صُمِّمت بعناية لتوفير أفضل تجربة للمريض والأخصائي',
            scrnPatient: 'تطبيق المريض', scrnTherapist: 'تطبيق الأخصائي',
            scrn1: 'قائمة الأخصائيين', scrn2: 'ملف الأخصائي', scrn3: 'حجز الموعد', scrn4: 'المحادثة', scrn5: 'البرامج المنزلية',
            scrn6: 'اللوحة الرئيسية', scrn7: 'جدول الدوام', scrn8: 'الريلز التثقيفية', scrn9: 'الأهداف العلاجية',
            ctaPatientH: 'تعاني من ألم أو إصابة؟',
            ctaPatientDesc: 'احصل على رعاية متخصصة من أفضل أخصائيي العلاج الطبيعي والوظيفي في فلسطين. ابدأ رحلة تعافيك اليوم من المنزل أو حضورياً.',
            ctaPatientBtn: 'حمّل تطبيق المريض',
            ctaTherapistH: 'أنت أخصائي علاج؟',
            ctaTherapistDesc: 'وسّع نطاق عملك ووصل لمرضى أكثر. أنشئ ملفك المهني، ارفع شهاداتك، وابدأ بإدارة مواعيدك ومتابعة مرضاك بشكل احترافي.',
            ctaTherapistBtn: 'حمّل تطبيق الأخصائي',
            dlH2: 'حمّل <span class="grad-text-red">نبض</span> الآن',
            dlPara: 'متاح مجاناً على أندرويد. ابدأ رحلتك نحو التعافي الكامل اليوم.',
            dlFrom: 'تحميل من', dlFrom2: 'تحميل من', dlPatientLabel: 'تطبيق المريض', dlTherapistLabel: 'تطبيق الأخصائي',
            dlFootnote: 'يتطلب أندرويد 8.0 أو أحدث',
            footerDesc: 'منصة العلاج الطبيعي والوظيفي الأولى في فلسطين. نربطك بالأخصائي المناسب لتعافٍ أسرع وأفضل.',
            footerLinks: 'روابط سريعة', footerLegal: 'قانوني', footerTerms: 'شروط الاستخدام', footerPrivacy: 'سياسة الخصوصية',
            footerCopy: '© ' + YEAR + ' نبض — NABD CARE. جميع الحقوق محفوظة.', footerMade: '🇵🇸 صُنع في فلسطين بـ ❤️',
        },
        he: {
            _title: 'נבד — פלטפורמת הפיזיותרפיה והריפוי בעיסוק בפלסטין',
            navAbout: 'אודות', navFeatures: 'תכונות', navScreens: 'מסכים', navDownload: 'הורדה',
            navAdmin: 'לוח ניהול', navAdminShort: 'ניהול',
            heroBadge: 'הפלטפורמה המובילה לפיזיותרפיה וריפוי בעיסוק בפלסטין',
            heroH1: 'הדרך שלך אל<br><span class="grad-text-red">החלמה מלאה</span>',
            heroPara: 'נבד מחבר אותך למיטב הפיזיותרפיסטים והמרפאים בעיסוק המוסמכים בפלסטין. הזמן פגישה אונליין או פנים אל פנים ועקוב אחר ההתקדמות שלך בכל פגישה.',
            heroCtaAndroid: 'הורד לאנדרואיד', heroCtaWatch: 'ראה איך זה עובד',
            heroStat1: 'מטפלים מוסמכים', heroStat2: 'פגישות שהושלמו', heroStat3: 'דירוג משתמשים',
            scrollMore: 'גלה עוד',
            about1Title: 'פיזיותרפיה', about1Desc: 'שיקום והפעלה מחדש של תנועה לאחר פציעות, ניתוחים ובעיות עצמות ומפרקים.',
            about2Title: 'ריפוי בעיסוק', about2Desc: 'עזרה למטופלים להחזיר את יכולותיהם היומיומיות ולחזור לחיים עצמאיים.',
            about3Title: 'שיקום', about3Desc: 'תוכניות שיקום מיוחדות לספורטאים ולחולים לאחר שבץ ופגיעות עצבים.',
            featBadge: '✨ תכונות הפלטפורמה', featH2: 'כל מה שצריך במקום אחד',
            featSub: 'פלטפורמה מקיפה שמשרתת מטופלים ומטפלים יחד ברמות האיכות הגבוהות ביותר',
            feat1Title: 'הזמנה קלה ומיידית', feat1Desc: 'הזמן פגישה בשניות. בחר את הזמן וסוג הפגישה (אונליין או פנים אל פנים) בלחיצה אחת.',
            feat2Title: 'תוכניות ביתיות', feat2Desc: 'המטפל שלך רושם תרגילים ביתיים מותאמים אישית עם תמונות וסרטוני הדרכה.',
            feat3Title: 'עקוב אחר ההתקדמות', feat3Desc: 'יעדים טיפוליים עם מד התקדמות. עקוב אחר המסע שלך מהפגישה הראשונה ועד החלמה מלאה.',
            feat4Title: 'סרטוני חינוך', feat4Desc: 'צפה בסרטוני מודעות ממטפלים מוסמכים על תרגילים ומניעת פציעות.',
            feat5Title: 'תקשורת ישירה', feat5Desc: 'צ׳אט עם המטפל שלך + שיחות קוליות ווידאו מאובטחות באפליקציה.',
            feat6Title: 'מטפלים מאומתים', feat6Desc: 'כל מטפל עובר בדיקה קפדנית ואימות של תעודותיו ורישיונו. איכות מובטחת.',
            howBadge: '⚡ איך זה עובד?', howH2: 'התחל את מסע ההחלמה ב-3 שלבים',
            how1Title: 'הורד את האפליקציה', how1Desc: 'צור חשבון כמטופל תוך פחות מדקה. אין צורך במידע מורכב.',
            how2Title: 'בחר את המטפל שלך', how2Desc: 'עיין ברשימת המטפלים המוסמכים, קרא ביקורות ובחר את המתאים ביותר למצבך.',
            how3Title: 'התחל טיפול', how3Desc: 'הזמן פגישה ועקוב אחר תוכנית הטיפול שלך עד החלמה מלאה.',
            scrnBadge: '📱 מסכי האפליקציה האמיתיים', scrnH2: 'חוויה חלקה וקלה לשימוש',
            scrnSub: 'כל מסך עוצב בקפידה כדי לספק את החוויה הטובה ביותר למטופל ולמטפל',
            scrnPatient: 'אפליקציית המטופל', scrnTherapist: 'אפליקציית המטפל',
            scrn1: 'רשימת מטפלים', scrn2: 'פרופיל המטפל', scrn3: 'הזמנת פגישה', scrn4: 'צ׳אט', scrn5: 'תוכניות ביתיות',
            scrn6: 'לוח הבקרה', scrn7: 'לוח זמנים', scrn8: 'סרטוני חינוך', scrn9: 'יעדים טיפוליים',
            ctaPatientH: 'סובל מכאב או פציעה?',
            ctaPatientDesc: 'קבל טיפול מקצועי ממיטב הפיזיותרפיסטים והמרפאים בעיסוק בפלסטין. התחל את מסע ההחלמה שלך היום מהבית או פנים אל פנים.',
            ctaPatientBtn: 'הורד אפליקציית מטופל',
            ctaTherapistH: 'אתה מטפל?',
            ctaTherapistDesc: 'הרחב את טווח הפעולה שלך והגע ליותר מטופלים. צור פרופיל מקצועי, העלה את האישורים שלך, והתחל לנהל פגישות ולעקוב אחר מטופלים במקצועיות.',
            ctaTherapistBtn: 'הורד אפליקציית מטפל',
            dlH2: 'הורד את <span class="grad-text-red">נבד</span> עכשיו',
            dlPara: 'זמין בחינם באנדרואיד. התחל את המסע שלך להחלמה מלאה היום.',
            dlFrom: 'הורד מ', dlFrom2: 'הורד מ', dlPatientLabel: 'אפליקציית מטופל', dlTherapistLabel: 'אפליקציית מטפל',
            dlFootnote: 'דורש אנדרואיד 8.0 ומעלה',
            footerDesc: 'פלטפורמת הפיזיותרפיה והריפוי בעיסוק המובילה בפלסטין. אנו מחברים אותך למטפל המתאים להחלמה מהירה וטובה יותר.',
            footerLinks: 'קישורים מהירים', footerLegal: 'משפטי', footerTerms: 'תנאי שימוש', footerPrivacy: 'מדיניות פרטיות',
            footerCopy: '© ' + YEAR + ' נבד — NABD CARE. כל הזכויות שמורות.', footerMade: '🇵🇸 נוצר בפלסטין עם ❤️',
        },
        en: {
            _title: 'NABD — Physical & Occupational Therapy Platform in Palestine',
            navAbout: 'About', navFeatures: 'Features', navScreens: 'Screens', navDownload: 'Download',
            navAdmin: 'Admin Panel', navAdminShort: 'Admin',
            heroBadge: "Palestine's #1 Physical & Occupational Therapy Platform",
            heroH1: 'Your Path to<br><span class="grad-text-red">Full Recovery</span>',
            heroPara: "NABD connects you with Palestine's best certified physical & occupational therapists. Book online or in-person and track your progress with every session.",
            heroCtaAndroid: 'Download for Android', heroCtaWatch: 'See How It Works',
            heroStat1: 'Certified Therapists', heroStat2: 'Completed Sessions', heroStat3: 'User Rating',
            scrollMore: 'Discover More',
            about1Title: 'Physical Therapy', about1Desc: 'Rehabilitation and movement recovery after injuries, surgeries, and bone & joint problems.',
            about2Title: 'Occupational Therapy', about2Desc: 'Helping patients regain daily abilities and return to independent living.',
            about3Title: 'Rehabilitation', about3Desc: 'Specialized rehab programs for athletes and patients after strokes and nerve injuries.',
            featBadge: '✨ Platform Features', featH2: 'Everything You Need in One Place',
            featSub: 'A complete platform serving both patients and therapists at the highest quality standards',
            feat1Title: 'Easy & Instant Booking', feat1Desc: 'Book your appointment in seconds. Choose your time and session type (online or in-person) with one tap.',
            feat2Title: 'Home Programs', feat2Desc: 'Your therapist prescribes personalized home exercises with images and instructional videos.',
            feat3Title: 'Track Your Progress', feat3Desc: 'Therapeutic goals with a progress tracker. Follow your journey from the first session to full recovery.',
            feat4Title: 'Educational Reels', feat4Desc: 'Watch awareness videos from certified therapists about exercises and injury prevention.',
            feat5Title: 'Direct Communication', feat5Desc: 'Chat with your therapist + secure audio and video calls in the app.',
            feat6Title: 'Verified Therapists', feat6Desc: 'Every therapist undergoes thorough review with credential and license verification. Quality guaranteed.',
            howBadge: '⚡ How Does It Work?', howH2: 'Start Your Recovery in 3 Steps',
            how1Title: 'Download the App', how1Desc: 'Create your patient account in under a minute. No complicated info needed.',
            how2Title: 'Choose Your Therapist', how2Desc: 'Browse the certified therapist list, read reviews, and pick the best for your condition.',
            how3Title: 'Start Treatment', how3Desc: 'Book your session and follow your treatment plan until full recovery.',
            scrnBadge: '📱 Real App Screens', scrnH2: 'Smooth & Easy-to-Use Experience',
            scrnSub: 'Every screen designed with care to provide the best experience for patients and therapists',
            scrnPatient: 'Patient App', scrnTherapist: 'Therapist App',
            scrn1: 'Therapist List', scrn2: 'Therapist Profile', scrn3: 'Booking', scrn4: 'Chat', scrn5: 'Home Programs',
            scrn6: 'Dashboard', scrn7: 'Schedule', scrn8: 'Educational Reels', scrn9: 'Therapeutic Goals',
            ctaPatientH: 'Suffering from Pain or Injury?',
            ctaPatientDesc: "Get specialized care from Palestine's best PT & OT therapists. Start your recovery journey today from home or in-person.",
            ctaPatientBtn: 'Download Patient App',
            ctaTherapistH: 'Are You a Therapist?',
            ctaTherapistDesc: 'Expand your reach and help more patients. Create your professional profile, upload your credentials, and start managing appointments and following up with patients professionally.',
            ctaTherapistBtn: 'Download Therapist App',
            dlH2: 'Download <span class="grad-text-red">NABD</span> Now',
            dlPara: 'Available free on Android. Start your journey to full recovery today.',
            dlFrom: 'Download from', dlFrom2: 'Download from', dlPatientLabel: 'Patient App', dlTherapistLabel: 'Therapist App',
            dlFootnote: 'Requires Android 8.0 or later',
            footerDesc: "Palestine's #1 physical & occupational therapy platform. We connect you with the right therapist for faster, better recovery.",
            footerLinks: 'Quick Links', footerLegal: 'Legal', footerTerms: 'Terms of Use', footerPrivacy: 'Privacy Policy',
            footerCopy: '© ' + YEAR + ' NABD — NABD CARE. All rights reserved.', footerMade: '🇵🇸 Made in Palestine with ❤️',
        }
    };

    function setLang(lang) {
        const dict = I18N[lang] || I18N.ar;
        const html = document.getElementById('rootHtml');
        html.setAttribute('lang', lang);
        html.setAttribute('dir', lang === 'en' ? 'ltr' : 'rtl');
        document.title = dict._title;
        document.querySelectorAll('[data-i18n]').forEach(el => {
            const key = el.getAttribute('data-i18n');
            if (dict[key] !== undefined) el.innerHTML = dict[key];
        });
        document.querySelectorAll('[data-lang-btn]').forEach(b => {
            b.classList.toggle('active', b.getAttribute('data-lang-btn') === lang);
        });
        try { localStorage.setItem('nabd_lang', lang); } catch (e) {}
    }

    // Apply saved language on load (default Arabic)
    let _saved = 'ar';
    try { _saved = localStorage.getItem('nabd_lang') || 'ar'; } catch (e) {}
    setLang(_saved);
</script>
</body>
</html>
