import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/network/api_client.dart';
import 'core/services/notification_service.dart';
import 'core/services/fcm_service.dart';
import 'core/services/locale_service.dart';
import 'core/services/app_settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize FCM (gets token, registers handlers)
  await FcmService.instance.init();

  // Seed AuthNotifier with persisted login state BEFORE runApp so the
  // GoRouter synchronous redirect works correctly from the very first frame.
  final storedToken = await ApiClient.getToken();
  AuthNotifier.instance.initialize(storedToken != null);

  await NotificationService.instance.init();

  // Fetch app settings (WhatsApp, announcements, etc.) — non-blocking
  unawaited(AppSettingsService.instance.init());

  // Load saved locale
  await LocaleService.instance.load();

  runApp(const NabdhTherapistApp());

  // Wire up notification navigation AFTER first frame so GoRouter is mounted.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    NotificationService.instance.setNavigator(
      (route, [extra]) => appRouter.push(route, extra: extra),
    );
  });
}

class NabdhTherapistApp extends StatefulWidget {
  const NabdhTherapistApp({super.key});

  @override
  State<NabdhTherapistApp> createState() => _NabdhTherapistAppState();
}

class _NabdhTherapistAppState extends State<NabdhTherapistApp> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleService.instance,
      builder: (_, __) {
        final locale = LocaleService.instance.locale;
        final isRtl  = locale.languageCode != 'en';
        return MaterialApp.router(
          key: ValueKey(locale.languageCode),
          title: 'نبض - الأخصائي',
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
