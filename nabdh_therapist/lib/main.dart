import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'core/services/fcm_service.dart';
import 'core/services/locale_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize FCM (gets token, registers handlers)
  await FcmService.instance.init();

  await NotificationService.instance.init();
  // Wire up navigation so notification taps can route correctly
  NotificationService.instance.setNavigator((route) => appRouter.push(route));

  // Load saved locale
  await LocaleService.instance.load();

  runApp(const NabdhTherapistApp());
}

class NabdhTherapistApp extends StatefulWidget {
  const NabdhTherapistApp({super.key});

  @override
  State<NabdhTherapistApp> createState() => _NabdhTherapistAppState();
}

class _NabdhTherapistAppState extends State<NabdhTherapistApp> {
  @override
  void initState() {
    super.initState();
    LocaleService.instance.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = LocaleService.instance.locale;
    // Hebrew is also RTL like Arabic
    final isRtl = locale.languageCode == 'ar' || locale.languageCode == 'he';

    return MaterialApp.router(
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
      builder: (context, child) => Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
    );
  }
}
