import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

const _kDone          = 'call_setup_done';
const _kLastShown     = 'call_setup_last_shown';
const _kAutoStartSeen = 'call_setup_autostart_opened';
const _native         = MethodChannel('com.nabdh/permissions');

/// Guides the user through the phone settings that let a call ring while the
/// app is closed (notifications, full-screen call, battery, vendor auto-start).
class CallSetupSheet extends StatefulWidget {
  const CallSetupSheet({super.key});

  static Future<void> show(BuildContext context) async {
    if (!Platform.isAndroid) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kLastShown, DateTime.now().millisecondsSinceEpoch);
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CallSetupSheet(),
    );
  }

  /// First launch, then at most once a day until everything is enabled
  /// or the user confirms with "تم".
  static Future<void> maybeShow(BuildContext context) async {
    if (!Platform.isAndroid) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kDone) ?? false) return;

    final status = await _SetupStatus.load();
    if (status.allDone) {
      await prefs.setBool(_kDone, true);
      return;
    }

    final last = prefs.getInt(_kLastShown) ?? 0;
    final since = DateTime.now().millisecondsSinceEpoch - last;
    if (since < const Duration(hours: 24).inMilliseconds) return;
    if (context.mounted) await show(context);
  }

  @override
  State<CallSetupSheet> createState() => _CallSetupSheetState();
}

class _SetupStatus {
  bool notifications = false;
  bool micCamera     = false;
  bool fullScreen    = false;
  bool overlay       = false;
  bool battery       = false;
  bool needsAutoStart = false;
  bool autoStartOpened = false;

  bool get allDone =>
      notifications && micCamera && fullScreen && overlay && battery &&
      (!needsAutoStart || autoStartOpened);

  static Future<_SetupStatus> load() async {
    final s = _SetupStatus();
    s.notifications = await Permission.notification.isGranted;
    s.micCamera = await Permission.microphone.isGranted &&
        await Permission.camera.isGranted;
    try {
      s.fullScreen = await FlutterCallkitIncoming.canUseFullScreenIntent();
    } catch (_) {
      s.fullScreen = true;
    }
    s.overlay = await Permission.systemAlertWindow.isGranted;
    s.battery = await Permission.ignoreBatteryOptimizations.isGranted;
    try {
      s.needsAutoStart = await _native.invokeMethod<bool>('needsAutoStart') ?? false;
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    s.autoStartOpened = prefs.getBool(_kAutoStartSeen) ?? false;
    return s;
  }
}

class _CallSetupSheetState extends State<CallSetupSheet>
    with WidgetsBindingObserver {
  _SetupStatus? _s;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Coming back from a settings screen → re-check what was enabled.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final s = await _SetupStatus.load();
    if (mounted) setState(() => _s = s);
  }

  Future<void> _request(Permission p) async {
    final st = await p.request();
    if (st.isPermanentlyDenied) await openAppSettings();
    await _refresh();
  }

  Future<void> _micCamera() async {
    final res = await [Permission.microphone, Permission.camera].request();
    if (res.values.any((s) => s.isPermanentlyDenied)) await openAppSettings();
    await _refresh();
  }

  Future<void> _fullScreen() async {
    try {
      await FlutterCallkitIncoming.requestFullIntentPermission();
    } catch (_) {
      await openAppSettings();
    }
  }

  Future<void> _autoStart() async {
    try {
      await _native.invokeMethod('openAutoStart');
    } catch (_) {
      await openAppSettings();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAutoStartSeen, true);
    await _refresh();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDone, true);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = _s;
    return Container(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: s == null
            ? const SizedBox(
                height: 240, child: Center(child: CircularProgressIndicator()))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Icon(Icons.ring_volume_rounded,
                        size: 44, color: AppColors.primary),
                    const SizedBox(height: 8),
                    const Text(
                      'حتى تصلك المكالمات وترنّ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'لكي يرنّ هاتفك عند الاتصال بك حتى لو كان التطبيق مغلقاً، '
                      'فعّل الخيارات التالية. اضغط على كل زر وسيفتح لك الإعداد مباشرة.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: AppColors.textSecondary,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Row(
                      icon: Icons.notifications_active_rounded,
                      title: 'الإشعارات',
                      subtitle: 'السماح للتطبيق بإظهار الإشعارات والمكالمات',
                      done: s.notifications,
                      action: 'تفعيل',
                      onTap: () => _request(Permission.notification),
                    ),
                    _Row(
                      icon: Icons.mic_rounded,
                      title: 'الميكروفون والكاميرا',
                      subtitle: 'لسماع صوتك وإظهار الفيديو أثناء المكالمة',
                      done: s.micCamera,
                      action: 'تفعيل',
                      onTap: _micCamera,
                    ),
                    _Row(
                      icon: Icons.fullscreen_rounded,
                      title: 'شاشة المكالمة الكاملة',
                      subtitle: 'إظهار شاشة الرد حتى والهاتف مقفل',
                      done: s.fullScreen,
                      action: 'فتح الإعدادات',
                      onTap: _fullScreen,
                    ),
                    _Row(
                      icon: Icons.picture_in_picture_alt_rounded,
                      title: 'العرض فوق التطبيقات',
                      subtitle: 'السماح بفتح شاشة المكالمة فوق أي تطبيق',
                      done: s.overlay,
                      action: 'فتح الإعدادات',
                      onTap: () => _request(Permission.systemAlertWindow),
                    ),
                    _Row(
                      icon: Icons.battery_charging_full_rounded,
                      title: 'إيقاف توفير البطارية لتطبيق نبض',
                      subtitle: 'حتى لا يوقف الهاتف التطبيق في الخلفية',
                      done: s.battery,
                      action: 'فتح الإعدادات',
                      onTap: () => _request(Permission.ignoreBatteryOptimizations),
                    ),
                    if (s.needsAutoStart)
                      _Row(
                        icon: Icons.restart_alt_rounded,
                        title: 'التشغيل التلقائي',
                        subtitle: 'مطلوب في هواتف شاومي وأوبو وهواوي وفيفو: '
                            'فعّل مفتاح «نبض» في الصفحة التي ستفتح',
                        done: s.autoStartOpened,
                        doneLabel: 'تم الفتح',
                        action: 'فتح الإعدادات',
                        onTap: _autoStart,
                      ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4E5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(children: [
                        Icon(Icons.info_outline_rounded,
                            color: Color(0xFFE65100), size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'بدون هذه الخيارات قد لا تصلك المكالمة إلا عند فتح التطبيق.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8A4B00),
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('لاحقاً',
                              style: TextStyle(fontFamily: 'Cairo')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: _finish,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('تم، فعّلتها',
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool done;
  final String doneLabel;
  final String action;
  final VoidCallback onTap;

  const _Row({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.done,
    required this.action,
    required this.onTap,
    this.doneLabel = 'مفعّل',
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: done ? const Color(0xFFEAF6EC) : AppColors.background,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
          color: done ? const Color(0xFFB7DFBE) : Colors.black12),
    ),
    child: Row(children: [
      Icon(icon,
          color: done ? AppColors.success : AppColors.primary, size: 26),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Cairo',
              )),
          const SizedBox(height: 2),
          Text(subtitle,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: AppColors.textSecondary,
                fontFamily: 'Cairo',
              )),
        ]),
      ),
      const SizedBox(width: 8),
      if (done)
        Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle_rounded,
              color: AppColors.success, size: 20),
          const SizedBox(width: 4),
          Text(doneLabel,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.success,
                fontWeight: FontWeight.w700,
                fontFamily: 'Cairo',
              )),
        ])
      else
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(action,
              style: const TextStyle(fontSize: 12, fontFamily: 'Cairo')),
        ),
    ]),
  );
}
