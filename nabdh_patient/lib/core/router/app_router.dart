import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/s.dart';
import '../network/api_client.dart';
import '../services/notification_service.dart';
import '../widgets/whatsapp_fab.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/phone_input_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/set_password_page.dart';
import '../../features/auth/presentation/pages/profile_setup_page.dart';
import '../../features/home/home_page.dart';
import '../../features/therapists/presentation/pages/therapist_list_page.dart';
import '../../features/therapists/presentation/pages/therapist_detail_page.dart';
import '../../features/therapists/presentation/pages/booking_page.dart';
import '../../features/appointments/presentation/pages/appointments_page.dart';
import '../../features/appointments/presentation/pages/appointment_detail_page.dart';
import '../../features/reels/presentation/pages/reels_feed_page.dart';
import '../../features/messages/presentation/pages/conversations_page.dart';
import '../../features/messages/presentation/pages/chat_page.dart';
import '../../features/messages/presentation/pages/call_screen.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/programs/presentation/pages/programs_page.dart';
import '../../features/programs/presentation/pages/program_detail_page.dart';
import '../../features/documents/presentation/pages/documents_page.dart';
import '../../features/goals/presentation/pages/goals_page.dart';
import '../../features/map/presentation/pages/map_page.dart';
import '../../features/profile/presentation/pages/static_page.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) async {
    final token      = await ApiClient.getToken();
    final isAuth     = token != null;
    final loc        = state.matchedLocation;
    final isSplash   = loc == '/splash';
    final isAuthRoute = loc.startsWith('/auth');

    // Routes that authenticated users are still allowed on (mid-registration flow)
    final isSetupRoute = loc == '/auth/setup' ||
                         loc == '/auth/set-password' ||
                         loc == '/auth/otp';

    final isOnboarding = loc == '/onboarding';

    if (isSplash || isOnboarding)              return null;
    if (!isAuth && !isAuthRoute)               return '/auth';
    if (isAuth  && isAuthRoute && !isSetupRoute) return '/home';
    return null;
  },
  routes: [
    GoRoute(path: '/splash',     builder: (_, __) => const SplashPage()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingPage()),

    // ── Auth ──────────────────────────────────────────────────────────
    GoRoute(path: '/auth',              builder: (_, __) => const WelcomePage()),
    GoRoute(path: '/auth/login',        builder: (_, __) => const LoginPage()),
    GoRoute(path: '/auth/register',     builder: (_, __) => const PhoneInputPage()),
    GoRoute(
      path: '/auth/otp',
      builder: (_, s) => OtpPage(phone: s.extra as String? ?? ''),
    ),
    GoRoute(
      path: '/auth/set-password',
      builder: (_, s) {
        final extra = s.extra as Map? ?? {};
        return SetPasswordPage(
          needsProfile: extra['needsProfile'] as bool? ?? true,
        );
      },
    ),
    GoRoute(path: '/auth/setup',        builder: (_, __) => const ProfileSetupPage()),

    // ── Main Shell ────────────────────────────────────────────────────
    ShellRoute(
      builder: (_, __, child) => PatientShell(child: child),
      routes: [
        GoRoute(path: '/home',         builder: (_, __) => const HomePage()),
        GoRoute(path: '/therapists',   builder: (_, __) => const TherapistListPage()),
        GoRoute(path: '/appointments', builder: (_, __) => const AppointmentsPage()),
        GoRoute(path: '/reels',        builder: (_, __) => const ReelsFeedPage()),
        GoRoute(path: '/messages',     builder: (_, __) => const ConversationsPage()),
        GoRoute(path: '/profile',      builder: (_, __) => const ProfilePage()),
      ],
    ),

    // ── Detail pages (outside shell) ─────────────────────────────────
    GoRoute(
      path: '/therapists/:id',
      builder: (_, s) =>
          TherapistDetailPage(id: int.parse(s.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/therapists/:id/book',
      builder: (_, s) =>
          BookingPage(therapistId: int.parse(s.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/appointments/:id',
      builder: (_, s) =>
          AppointmentDetailPage(id: int.parse(s.pathParameters['id']!)),
    ),
    // NOTE: /messages/new must be declared BEFORE /messages/:id to avoid
    // GoRouter matching the literal "new" as the :id parameter.
    GoRoute(
      path: '/messages/new',
      builder: (_, s) {
        final extra = s.extra as Map? ?? {};
        return ChatPage(
          conversationId: 0,
          newConvoPartnerId: extra['partnerId'] as int?,
          newConvoName:      extra['name']      as String?,
        );
      },
    ),
    GoRoute(
      path: '/messages/:id',
      builder: (_, s) {
        final extra = s.extra as Map? ?? {};
        return ChatPage(
          conversationId: int.parse(s.pathParameters['id']!),
          newConvoPartnerId: extra['partnerId'] as int?,
          newConvoName: extra['name'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/programs/:id',
      builder: (_, s) =>
          ProgramDetailPage(id: int.parse(s.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/call',
      builder: (_, s) {
        final extra = s.extra as Map? ?? {};
        return CallScreen(
          channel:      extra['channel'] as String? ?? '',
          appId:        extra['appId']   as String? ?? '',
          isVideo:      extra['isVideo'] as bool?   ?? false,
          partnerName:  extra['name']    as String? ?? 'مكالمة',
          uid:          extra['uid']     as int?    ?? 0,
        );
      },
    ),
    GoRoute(
      path: '/notifications',
      builder: (_, __) => const NotificationsPage(),
    ),
    GoRoute(
      path: '/goals',
      builder: (_, __) => const PatientGoalsPage(),
    ),
    GoRoute(
      path: '/map',
      builder: (_, __) => const TherapistMapPage(),
    ),
    GoRoute(
      path: '/programs',
      builder: (_, __) => const ProgramsPage(),
    ),
    GoRoute(
      path: '/documents',
      builder: (_, __) => const DocumentsPage(),
    ),
    GoRoute(
      path: '/terms',
      builder: (_, __) => const StaticPage(slug: 'terms'),
    ),
    GoRoute(
      path: '/privacy',
      builder: (_, __) => const StaticPage(slug: 'privacy'),
    ),
  ],
);

// ── PatientShell ──────────────────────────────────────────────────────────
class PatientShell extends StatefulWidget {
  final Widget child;
  const PatientShell({required this.child, super.key});
  @override
  State<PatientShell> createState() => _PatientShellState();
}

class _PatientShellState extends State<PatientShell> {
  int _idx    = 0;
  int _unread = 0;
  final _tabs = ['/home', '/therapists', '/appointments', '/reels', '/messages', '/profile'];

  @override
  void initState() {
    super.initState();
    NotificationService.instance.unreadCount.addListener(_onUnread);
    _unread = NotificationService.instance.unreadCount.value;
  }

  @override
  void dispose() {
    NotificationService.instance.unreadCount.removeListener(_onUnread);
    super.dispose();
  }

  void _onUnread() {
    if (mounted) setState(() => _unread = NotificationService.instance.unreadCount.value);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: widget.child,
    floatingActionButton: const WhatsAppFab(),
    floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    bottomNavigationBar: NavigationBar(
      selectedIndex: _idx,
      onDestinationSelected: (i) {
        setState(() => _idx = i);
        context.go(_tabs[i]);
      },
      destinations: [
        NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: S.home),
        NavigationDestination(
            icon: const Icon(Icons.search_outlined),
            selectedIcon: const Icon(Icons.search_rounded),
            label: S.therapists),
        NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month_rounded),
            label: S.appointments),
        NavigationDestination(
            icon: const Icon(Icons.play_circle_outline_rounded),
            selectedIcon: const Icon(Icons.play_circle_rounded),
            label: S.reels),
        NavigationDestination(
          icon: _unread > 0
              ? Badge(label: Text('$_unread'), child: const Icon(Icons.chat_outlined))
              : const Icon(Icons.chat_outlined),
          selectedIcon: _unread > 0
              ? Badge(label: Text('$_unread'), child: const Icon(Icons.chat_rounded))
              : const Icon(Icons.chat_rounded),
          label: S.messages,
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline_rounded),
          selectedIcon: const Icon(Icons.person_rounded),
          label: S.myAccount,
        ),
      ],
    ),
  );
}
