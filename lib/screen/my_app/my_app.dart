import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/screen/languages_screen/languages_screen_controller.dart';
import 'package:doctor_flutter/screen/my_app/my_app_controller.dart';
import 'package:doctor_flutter/screen/splash_screen/splash_screen.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      onInit: () => Get.put(MyAppController()),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: Locale(LanguagesScreenController.selectedLanguage),
      supportedLocales: S.delegate.supportedLocales,
      // Force RTL for all screens
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00685d),
            foregroundColor: ColorRes.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        fontFamily: FontRes.productSansRegular,
        useMaterial3: false,
      ),
      home: const SplashScreen(),
    );
  }
}
