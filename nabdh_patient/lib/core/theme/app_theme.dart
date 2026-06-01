import 'package:flutter/material.dart';

// ─── NABD CARE Brand Colors ────────────────────────────────────────────────
// Navy  #1B2E6E  (NABD text in logo)
// Red   #D42B24  (CARE text + heartbeat line)
// Gray  #8FA0AD  (wheelchair icon)
class AppColors {
  // Primary brand – navy blue
  static const Color primary      = Color(0xFF1B2E6E);
  static const Color primaryLight = Color(0xFF2D4A9E);
  static const Color primaryDark  = Color(0xFF0F1D48);

  // Secondary brand – red
  static const Color accent       = Color(0xFFD42B24);
  static const Color accentLight  = Color(0xFFEA5550);
  static const Color accentDark   = Color(0xFF9E1E19);

  // Brand gray (wheelchair)
  static const Color brandGray    = Color(0xFF8FA0AD);

  // Backgrounds & surfaces
  static const Color background   = Color(0xFFF4F6FB);
  static const Color surface      = Color(0xFFFFFFFF);
  static const Color surfaceAlt   = Color(0xFFEEF1F8);

  // Text
  static const Color textPrimary  = Color(0xFF0F1D48);
  static const Color textSecondary= Color(0xFF5A6A80);
  static const Color textHint     = Color(0xFFAAB4C5);

  // Borders
  static const Color border       = Color(0xFFDDE3F0);
  static const Color borderLight  = Color(0xFFEEF1F8);

  // Semantic
  static const Color success      = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning      = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error        = Color(0xFFD42B24);
  static const Color errorLight   = Color(0xFFFFEBEE);

  static const Color purple       = Color(0xFF5C35D4);
  static const Color purpleLight  = Color(0xFFEDE7FF);
  static const Color cardShadow   = Color(0x12000000);
}

class AppGradients {
  // Main brand gradient – navy
  static const LinearGradient primary = LinearGradient(
    colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  // Red accent gradient
  static const LinearGradient accent = LinearGradient(
    colors: [AppColors.accentDark, AppColors.accent, AppColors.accentLight],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  // Hero gradient used on splash & top banners
  static const LinearGradient hero = LinearGradient(
    colors: [Color(0xFF0F1D48), Color(0xFF1B2E6E), Color(0xFF2D4A9E)],
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
  );
  static const LinearGradient card = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryLight],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient warm = LinearGradient(
    colors: [AppColors.accent, AppColors.accentLight],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Cairo',
    colorScheme: const ColorScheme.light(
      primary:    AppColors.primary,
      secondary:  AppColors.accent,
      surface:    AppColors.surface,
      error:      AppColors.error,
      onPrimary:  Colors.white,
      onSecondary: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700),
        elevation: 0,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: const Color(0x1F1B2E6E),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary);
        }
        return const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondary);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary, size: 24);
        }
        return const IconThemeData(color: AppColors.textSecondary, size: 22);
      }),
      height: 68,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceAlt,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface, elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge:  TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      titleLarge:     TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      titleMedium:    TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      bodyLarge:      TextStyle(fontSize: 15, color: AppColors.textPrimary),
      bodyMedium:     TextStyle(fontSize: 14, color: AppColors.textSecondary),
      labelLarge:     TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
  );
}
