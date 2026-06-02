import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:workmanager/workmanager.dart';
import 'core/constants/app_constants.dart';
import 'core/utils/json_utils.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'core/services/fcm_service.dart';
import 'core/services/locale_service.dart';
import 'core/services/app_settings_service.dart';

// ─── WorkManager background task ─────────────────────────────────────────────
// Must be a top-level function annotated with vm:entry-point
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, _) async {
    if (task == _kPollTask) await _backgroundPoll();
    return true;
  });
}

const _kPollTask = 'nabdh_poll_notifications';

/// Runs in a separate Dart isolate — cannot use singletons from the main isolate.
Future<void> _backgroundPoll() async {
  try {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: AppConstants.tokenKey);
    if (token == null) return;

    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    // Check unread count first (cheap call)
    final countRes = await dio.get('/notifications/unread-count');
    final count = jsonInt(countRes.data['count']);
    if (count <= 0) return;

    // Fetch latest notifications
    final listRes = await dio.get('/notifications', queryParameters: {'per_page': 5});
    final raw  = listRes.data;
    final list = ((raw is Map ? raw['data'] : raw) as List?) ?? [];

    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher')),
      onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationTap,
    );

    for (final item in list) {
      final n = item as Map<String, dynamic>;
      if (n['read_at'] != null) continue;

      final dataField = n['data'];
      final dataMap   = dataField is Map
          ? dataField.cast<String, dynamic>()
          : <String, dynamic>{};

      final aptId   = dataMap['appointment_id'];
      final payload = aptId != null ? 'appointment:$aptId' : null;

      await plugin.show(
        jsonInt(n['id']),
        n['title'] as String? ?? 'نبض',
        n['body']  as String? ?? '',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'nabdh_patient_channel', 'إشعارات نبض',
            importance: Importance.high,
            priority:   Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: payload,
      );
    }
  } catch (_) {}
}

// ─── App entry point ──────────────────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize FCM (gets token, registers handlers)
  await FcmService.instance.init();

  // Initialise local notifications + polling
  await NotificationService.instance.init();

  // Fetch app settings (WhatsApp, announcements, etc.) — non-blocking
  unawaited(AppSettingsService.instance.init());

  // Register WorkManager for background polling (every 15 min, Wi-Fi/data required)
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  await Workmanager().registerPeriodicTask(
    _kPollTask,
    _kPollTask,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingWorkPolicy.keep,
    backoffPolicy: BackoffPolicy.linear,
    backoffPolicyDelay: const Duration(minutes: 5),
  );

  // Load saved locale
  await LocaleService.instance.load();

  // Wire up navigation BEFORE runApp so the pending-payload check works
  NotificationService.instance.setNavigator((route) => appRouter.push(route));

  runApp(const NabdhPatientApp());
}

class NabdhPatientApp extends StatefulWidget {
  const NabdhPatientApp({super.key});

  @override
  State<NabdhPatientApp> createState() => _NabdhPatientAppState();
}

class _NabdhPatientAppState extends State<NabdhPatientApp> {
  @override
  Widget build(BuildContext context) {
    // ListenableBuilder listens to LocaleService and rebuilds MaterialApp.router.
    // key: ValueKey(lang) forces GoRouter to fully reinitialise on locale change
    // (otherwise GoRouter's internal navigator ignores the parent rebuild).
    return ListenableBuilder(
      listenable: LocaleService.instance,
      builder: (_, __) {
        final locale = LocaleService.instance.locale;
        final isRtl  = locale.languageCode != 'en';
        return MaterialApp.router(
          key: ValueKey(locale.languageCode),
          title: 'نبض',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: appRouter,
          locale: locale,
          supportedLocales: LocaleService.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (ctx, child) => Directionality(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: child!,
          ),
        );
      },
    );
  }
}
