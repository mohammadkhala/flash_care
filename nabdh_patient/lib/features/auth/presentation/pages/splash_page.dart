import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/nabd_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _textFade;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _fadeAnim  = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn);
    _textFade  = CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn);

    _logoCtrl.forward().then((_) => _textCtrl.forward());
    _navigate();
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    // If the app was opened by tapping a notification, skip the long animation
    // so the notification's push() fires AFTER we've reached /home.
    final hasNotif = NotificationService.hadPendingAtStartup;
    await Future.delayed(Duration(milliseconds: hasNotif ? 300 : 2200));
    if (!mounted) return;
    final token  = await ApiClient.getToken();
    final prefs  = await SharedPreferences.getInstance();
    final sawOnb = prefs.getBool('onboarding_v2_seen') ?? false;
    if (!mounted) return;
    if (token != null) {
      context.go('/home');
    } else if (!sawOnb) {
      context.go('/onboarding');
    } else {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: AppGradients.hero),
      child: SafeArea(
        child: Align(
          alignment: const Alignment(0, -0.28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Animated Logo ───────────────────────────────────────
              FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: const NabdLogo(size: 110, onDark: true),
                ),
              ),
              const SizedBox(height: 32),
              // ── Tagline ─────────────────────────────────────────────
              FadeTransition(
                opacity: _textFade,
                child: Column(children: [
                  const Text(
                    'ابحث عن أخصائيين التأهيل',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Cairo',
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'واحصل على جلسات عن بُعد',
                    style: TextStyle(
                      color: Colors.white.withAlpha(210),
                      fontSize: 15,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'تطبيق المريض',
                    style: TextStyle(
                      color: Colors.white.withAlpha(150),
                      fontSize: 12,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 60),
              // ── Loading dots ─────────────────────────────────────────
              FadeTransition(
                opacity: _textFade,
                child: const _PulseDots(),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _PulseDots extends StatefulWidget {
  const _PulseDots();
  @override
  State<_PulseDots> createState() => _PulseDotsState();
}

class _PulseDotsState extends State<_PulseDots> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) => Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final delay = i / 3;
        final value = ((_ctrl.value - delay) % 1.0).clamp(0.0, 1.0);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8, height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withAlpha((80 + (value * 175).round())),
          ),
        );
      }),
    ),
  );
}
