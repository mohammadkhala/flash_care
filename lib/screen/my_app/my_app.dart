import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/languages_screen/languages_screen_controller.dart';
import 'package:patient_flutter/screen/my_app/my_app_controller.dart';
import 'package:patient_flutter/screen/splash_screen/splash_screen.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/font_res.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MyAppController());
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      locale: Locale(LanguagesScreenController.selectedLanguage),
      supportedLocales: S.delegate.supportedLocales,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: ScrollConfiguration(behavior: MyScrollBehavior(), child: child!),
        );
      },
      theme: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00685d),
            primary: const Color(0xFF00685d),
            secondary: const Color(0xFF046b5e),
            surface: ColorRes.white,
          ),
          scaffoldBackgroundColor: const Color(0xFFF6FAF8),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF6FAF8),
            foregroundColor: Color(0xFF171D1B),
            elevation: 0,
          ),
          cardTheme: CardTheme(
            color: ColorRes.white,
            elevation: 0,
            shadowColor: const Color(0xFF00685d).withValues(alpha: .08),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00685d),
              foregroundColor: ColorRes.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              textStyle: const TextStyle(fontFamily: FontRes.productSansMedium, fontSize: 16),
            ),
          ),
          fontFamily: FontRes.productSansRegular,
          useMaterial3: false),
      home: const SplashScreen(),
    );
  }
}

class MyScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
