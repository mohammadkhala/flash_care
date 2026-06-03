import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/s.dart';
import '../services/notification_service.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/phone_input_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/set_password_page.dart';
import '../../features/auth/presentation/pages/profile_setup_page.dart';
import '../../features/auth/presentation/pages/pending_approval_page.dart';
import '../../features/home/home_page.dart';
import '../../features/appointments/presentation/pages/appointments_page.dart';
import '../../features/appointments/presentation/pages/appointment_detail_page.dart';
import '../../features/messages/presentation/pages/conversations_page.dart';
import '../../features/messages/presentation/pages/chat_page.dart';
import '../../features/programs/presentation/pages/programs_page.dart';
import '../../features/programs/presentation/pages/create_program_page.dart';
import '../../features/reels/presentation/pages/reels_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/statistics/statistics_page.dart' show StatisticsPage;
import '../../features/articles/presentation/pages/articles_page.dart';
import '../../features/articles/presentation/pages/create_article_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/calls/presentation/pages/webrtc_call_page.dart';
import '../../features/calls/presentation/pages/incoming_call_page.dart';
import '../../features/assessments/presentation/pages/assessment_page.dart';
import '../../features/schedule/presentation/pages/schedule_page.dart';
import '../../features/goals/presentation/pages/goals_page.dart';
import '../../features/goals/presentation/pages/goal_detail_page.dart';
import '../../features/profile/presentation/pages/static_page.dart';
import '../network/api_client.dart';
import '../widgets/whatsapp_fab.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) async {
    final token     = await ApiClient.getToken();
    final isAuth    = token != null;
    final loc       = state.matchedLocation;
    final isAuthRoute     = loc.startsWith('/auth');
    final isSplash        = loc == '/splash';
    final isPostAuthSetup = loc == '/auth/set-password' ||
                            loc == '/auth/setup'        ||
                            loc == '/auth/pending';

    final isOnboarding = loc == '/onboarding';

    if (isSplash || isPostAuthSetup || isOnboarding) return null;
    if (!isAuth && !isAuthRoute) return '/auth';
    if (isAuth && isAuthRoute) return '/home';
    return null;
  },
  routes: [
    GoRoute(path: '/splash',     builder: (_, __) => const SplashPage()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingPage()),

    // ── Auth flow ─────────────────────────────────────────────
    GoRoute(path: '/auth',          builder: (_, __) => const WelcomePage()),
    GoRoute(path: '/auth/login',    builder: (_, __) => const LoginPage()),
    GoRoute(path: '/auth/register', builder: (_, __) => const PhoneInputPage()),
    GoRoute(
      path: '/auth/otp',
      builder: (_, state) => OtpPage(phone: state.extra as String),
    ),
    GoRoute(
      path: '/auth/set-password',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return SetPasswordPage(
          needsProfile: extra['needsProfile'] as bool? ?? true,
          isApproved:   extra['isApproved']   as bool? ?? true,
        );
      },
    ),
    GoRoute(path: '/auth/setup',    builder: (_, __) => const ProfileSetupPage()),
    GoRoute(path: '/auth/pending',  builder: (_, __) => const PendingApprovalPage()),

    // ── Video call (full screen, outside shell) ───────────────
    GoRoute(
      path: '/call',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return WebRtcCallPage(
          conversationId: extra['conversationId'] as int? ?? 0,
          peerName:       extra['peerName']       as String? ?? 'المريض',
          isVideo:        extra['isVideo']        as bool?   ?? true,
          isCaller:       extra['isCaller']       as bool?   ?? true,
          incomingChannel: extra['channel']       as String?,
        );
      },
    ),
    GoRoute(
      path: '/incoming-call',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return IncomingCallPage(
          channel:    extra['channel']    as String? ?? '',
          callerName: extra['callerName'] as String? ?? 'مكالمة',
          isVideo:    extra['isVideo']    as bool?   ?? false,
        );
      },
    ),

    // ── Main shell with bottom nav ────────────────────────────
    ShellRoute(
      builder: (context, state, child) => HomeShell(child: child),
      routes: [
        GoRoute(path: '/home',          builder: (_, __) => const HomePage()),
        GoRoute(path: '/appointments',  builder: (_, __) => const AppointmentsPage()),
        GoRoute(
          path: '/appointments/:id',
          builder: (_, state) => AppointmentDetailPage(id: int.parse(state.pathParameters['id']!)),
        ),
        GoRoute(path: '/messages',      builder: (_, __) => const ConversationsPage()),
        GoRoute(
          path: '/messages/new',
          builder: (_, state) {
            final extra = state.extra as Map? ?? {};
            return ChatPage(
              conversationId: 0,
              newConvoPartnerId: extra['partnerId'] as int?,
              newConvoName: extra['name'] as String?,
            );
          },
        ),
        GoRoute(
          path: '/messages/:id',
          builder: (_, state) {
            final extra = state.extra as Map? ?? {};
            return ChatPage(
              conversationId: int.parse(state.pathParameters['id']!),
              newConvoPartnerId: extra['partnerId'] as int?,
              newConvoName: extra['name'] as String?,
            );
          },
        ),
        GoRoute(path: '/programs',        builder: (_, __) => const ProgramsPage()),
        GoRoute(path: '/programs/create', builder: (_, __) => const CreateProgramPage()),
        GoRoute(path: '/reels',           builder: (_, __) => const ReelsPage()),
        GoRoute(path: '/profile',         builder: (_, __) => const ProfilePage()),
        GoRoute(path: '/profile/edit',    builder: (_, __) => const EditProfilePage()),
        GoRoute(path: '/statistics',      builder: (_, __) => const StatisticsPage()),
        GoRoute(path: '/articles',        builder: (_, __) => const ArticlesPage()),
        GoRoute(
          path: '/articles/create',
          builder: (_, __) => const CreateArticlePage(),
        ),
        GoRoute(
          path: '/articles/edit',
          builder: (_, state) => CreateArticlePage(article: state.extra as Map?),
        ),
        GoRoute(path: '/notifications',   builder: (_, __) => const NotificationsPage()),
        GoRoute(path: '/schedule', builder: (_, __) => const SchedulePage()),
        GoRoute(
          path: '/goals',
          builder: (_, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return GoalsPage(
              patientId:   extra['patientId']   as int?    ?? 0,
              patientName: extra['patientName'] as String? ?? 'المريض',
            );
          },
        ),
        GoRoute(
          path: '/goals/:id',
          builder: (_, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return GoalDetailPage(
              goalId:  int.parse(state.pathParameters['id']!),
              goal:    extra['goal'] as Map<String, dynamic>? ?? {},
              canEdit: extra['canEdit'] as bool? ?? true,
            );
          },
        ),
        GoRoute(
          path: '/assessment',
          builder: (_, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return AssessmentPage(
              patientId: extra['patientId'] as int? ?? 0,
              type: (extra['type'] as String?) == 'gad7'
                  ? AssessmentType.gad7
                  : AssessmentType.phq9,
            );
          },
        ),
        GoRoute(path: '/terms',   builder: (_, __) => const StaticPage(slug: 'terms')),
        GoRoute(path: '/privacy', builder: (_, __) => const StaticPage(slug: 'privacy')),
      ],
    ),
  ],
);

class HomeShell extends StatefulWidget {
  final Widget child;
  const HomeShell({required this.child, super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;
  int _unreadNotifications = 0;

  final _tabs = ['/home', '/appointments', '/messages', '/reels', '/programs', '/profile'];

  @override
  void initState() {
    super.initState();
    NotificationService.instance.unreadCount.addListener(_onUnreadChanged);
    _unreadNotifications = NotificationService.instance.unreadCount.value;
  }

  @override
  void dispose() {
    NotificationService.instance.unreadCount.removeListener(_onUnreadChanged);
    super.dispose();
  }

  void _onUnreadChanged() {
    if (mounted) setState(() => _unreadNotifications = NotificationService.instance.unreadCount.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) {
          setState(() => _selectedIndex = i);
          context.go(_tabs[i]);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: S.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: S.appointments,
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_outlined),
            selectedIcon: const Icon(Icons.chat),
            label: S.messages,
          ),
          NavigationDestination(
            icon: const Icon(Icons.play_circle_outline_rounded),
            selectedIcon: const Icon(Icons.play_circle_rounded),
            label: S.reels,
          ),
          NavigationDestination(
            icon: const Icon(Icons.fitness_center_outlined),
            selectedIcon: const Icon(Icons.fitness_center),
            label: S.programs,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: S.myProfile,
          ),
        ],
      ),
    );
  }
}
