<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'لوحة التحكم') - NABD CARE</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>
    <style>
        * { font-family: 'Cairo', sans-serif; }

        /* ── Sidebar item states ─────────────────────────────────── */
        .sidebar-item.active {
            background: rgba(255,255,255,0.18);
            border-right: 3px solid #D42B24;
            color: #fff;
        }
        .sidebar-item:hover { background: rgba(255,255,255,0.1); }

        /* ── Scrollbar ───────────────────────────────────────────── */
        ::-webkit-scrollbar { width: 5px; height: 5px; }
        ::-webkit-scrollbar-track { background: #f1f1f1; }
        ::-webkit-scrollbar-thumb { background: #1B2E6E44; border-radius: 99px; }

        /* ── Brand colors as utilities ───────────────────────────── */
        .bg-brand   { background: linear-gradient(160deg, #0F1D48 0%, #1B2E6E 60%, #2D4A9E 100%); }
        .text-brand { color: #1B2E6E; }
        .text-red   { color: #D42B24; }
        .badge-red  { background: #D42B24; color: #fff; }
        .badge-navy { background: #1B2E6E; color: #fff; }

        /* ── Stat card hover ────────────────────────────────────── */
        .stat-card { transition: transform 0.2s, box-shadow 0.2s; }
        .stat-card:hover { transform: translateY(-3px); box-shadow: 0 8px 24px #1B2E6E1A; }
    </style>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: { DEFAULT: '#1B2E6E', light: '#2D4A9E', dark: '#0F1D48' },
                        brand:   { red: '#D42B24', gray: '#8FA0AD' },
                    }
                }
            }
        }
    </script>
</head>
<body class="bg-gray-50 text-gray-900" x-data="{ sidebarOpen: true }">

<div class="flex min-h-screen">

    {{-- ── Sidebar ────────────────────────────────────────────────── --}}
    <aside class="bg-brand text-white flex flex-col shadow-2xl transition-all duration-300 flex-shrink-0"
           :class="sidebarOpen ? 'w-64' : 'w-16'">

        {{-- Logo area --}}
        <div class="h-16 flex items-center px-4 border-b border-white/15 gap-3">
            {{-- Mini heartbeat icon --}}
            <svg viewBox="0 0 32 20" class="w-8 flex-shrink-0" fill="none">
                <line x1="0" y1="10" x2="6" y2="10" stroke="#D42B24" stroke-width="2" stroke-linecap="round"/>
                <polyline points="6,10 10,2 13,18 16,5 19,13 22,10 32,10"
                          stroke="#D42B24" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
            </svg>
            <div x-show="sidebarOpen" class="leading-tight">
                <div class="font-black tracking-wider text-lg leading-none">NABD <span style="color:#D42B24">CARE</span></div>
                <div class="text-white/50 text-xs">لوحة الإدارة</div>
            </div>
        </div>

        {{-- Nav --}}
        <nav class="flex-1 py-4 overflow-y-auto space-y-0.5 px-2">
            @php
                $navItems = [
                    ['route' => 'admin.dashboard',            'icon' => '📊', 'label' => 'لوحة التحكم'],
                    ['route' => 'admin.therapists.index',     'icon' => '👨‍⚕️', 'label' => 'الأخصائيون'],
                    ['route' => 'admin.patients.index',       'icon' => '🧑‍🤝‍🧑', 'label' => 'المرضى'],
                    ['route' => 'admin.appointments.index',   'icon' => '📅', 'label' => 'المواعيد'],
                    ['route' => 'admin.reels.index',          'icon' => '🎬', 'label' => 'الريلز'],
                    ['route' => 'admin.specializations.index','icon' => '🏷️', 'label' => 'التخصصات'],
                    ['route' => 'admin.map.index',            'icon' => '🗺️', 'label' => 'الخريطة'],
                    ['route' => 'admin.pages.index',          'icon' => '📄', 'label' => 'الصفحات'],
                    ['route' => 'admin.settings.index',       'icon' => '⚙️', 'label' => 'الإعدادات'],
                ];
            @endphp

            @foreach($navItems as $item)
                <a href="{{ route($item['route']) }}"
                   class="sidebar-item flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm transition-all cursor-pointer
                          {{ request()->routeIs($item['route']) ? 'active font-semibold' : 'text-white/75 hover:text-white' }}">
                    <span class="text-xl leading-none flex-shrink-0">{{ $item['icon'] }}</span>
                    <span x-show="sidebarOpen" x-transition>{{ $item['label'] }}</span>
                </a>
            @endforeach
        </nav>

        {{-- User / Logout --}}
        <div class="p-3 border-t border-white/15">
            <form method="POST" action="{{ route('logout') }}">
                @csrf
                <button class="w-full flex items-center gap-3 text-white/60 hover:text-white text-sm
                               transition-colors px-3 py-2.5 rounded-xl hover:bg-white/10">
                    <span class="text-lg flex-shrink-0">🚪</span>
                    <span x-show="sidebarOpen" x-transition>تسجيل الخروج</span>
                </button>
            </form>
        </div>
    </aside>

    {{-- ── Main ────────────────────────────────────────────────────── --}}
    <div class="flex-1 flex flex-col overflow-hidden">

        {{-- Top Bar --}}
        <header class="h-16 bg-white border-b border-gray-100 flex items-center justify-between px-6 shadow-sm">
            <div class="flex items-center gap-4">
                <button @click="sidebarOpen = !sidebarOpen"
                        class="text-gray-400 hover:text-gray-600 transition-colors">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
                    </svg>
                </button>
                <div>
                    <h1 class="text-base font-bold text-brand leading-none">@yield('title', 'لوحة التحكم')</h1>
                    <p class="text-xs text-gray-400 mt-0.5">@yield('subtitle', 'NABD CARE Admin')</p>
                </div>
            </div>
            <div class="flex items-center gap-3">
                <span class="text-xs text-gray-400 hidden sm:block">{{ now()->format('Y/m/d') }}</span>
                <div class="w-9 h-9 rounded-full flex items-center justify-center text-white font-bold text-sm shadow-md"
                     style="background: linear-gradient(135deg, #1B2E6E, #2D4A9E);">أ</div>
            </div>
        </header>

        {{-- Flash Messages --}}
        @if(session('success'))
            <div class="mx-6 mt-4 bg-green-50 border border-green-200 text-green-800 px-4 py-3 rounded-xl flex items-center gap-2 text-sm"
                 x-data="{show: true}" x-show="show" x-init="setTimeout(() => show = false, 4000)">
                <span>✅</span> {{ session('success') }}
            </div>
        @endif
        @if(session('error'))
            <div class="mx-6 mt-4 bg-red-50 border border-red-200 text-red-800 px-4 py-3 rounded-xl flex items-center gap-2 text-sm">
                <span>❌</span> {{ session('error') }}
            </div>
        @endif

        {{-- Page Content --}}
        <main class="flex-1 overflow-y-auto p-6">
            @yield('content')
        </main>
    </div>
</div>

@stack('scripts')
</body>
</html>
