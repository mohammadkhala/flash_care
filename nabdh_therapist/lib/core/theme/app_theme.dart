import 'package:flutter/material.dart';

// ─── NABD CARE Brand Colors ────────────────────────────────────────────────
// Navy  #1B2E6E  (NABD text in logo)
// Red   #D42B24  (CARE text + heartbeat line)
// Gray  #8FA0AD  (wheelchair icon)
class AppColors {
  // Primary brand – navy blue
  static const primary      = Color(0xFF1B2E6E);
  static const primaryLight = Color(0xFF2D4A9E);
  static const primaryDark  = Color(0xFF0F1D48);

  // Secondary brand – red
  static const accent       = Color(0xFFD42B24);
  static const accentLight  = Color(0xFFEA5550);
  static const accentDark   = Color(0xFF9E1E19);

  // Brand gray (wheelchair)
  static const brandGray    = Color(0xFF8FA0AD);

  // Backgrounds & surfaces
  static const background   = Color(0xFFF4F6FB);
  static const surface      = Color(0xFFFFFFFF);
  static const surfaceAlt   = Color(0xFFEEF1F8);

  // Text
  static const textPrimary  = Color(0xFF0F1D48);
  static const textSecondary= Color(0xFF5A6A80);
  static const textHint     = Color(0xFFAAB4C5);

  // Borders
  static const border       = Color(0xFFDDE3F0);
  static const borderLight  = Color(0xFFEEF1F8);

  // Semantic
  static const success      = Color(0xFF2E7D32);
  static const successLight = Color(0xFF4CAF50);
  static const warning      = Color(0xFFE65100);
  static const warningLight = Color(0xFFFF9800);
  static const error        = Color(0xFFD42B24);
  static const errorLight   = Color(0xFFEA5550);

  static const cardShadow   = Color(0x12000000);
}

class AppGradients {
  // Main brand gradient – navy
  static const primary = LinearGradient(
    colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  // Red accent gradient
  static const accent = LinearGradient(
    colors: [AppColors.accentDark, AppColors.accent, AppColors.accentLight],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  // Hero gradient used on splash & top banners
  static const hero = LinearGradient(
    colors: [Color(0xFF0F1D48), Color(0xFF1B2E6E), Color(0xFF2D4A9E)],
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
  );
  static const success = LinearGradient(
    colors: [AppColors.success, AppColors.successLight],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
}

class AppTheme {
  /// Text theme built on the bundled Cairo family.
  ///
  /// This used to call GoogleFonts.cairo(), which fetches the font from
  /// fonts.gstatic.com on first launch; when that fetch fails the app silently
  /// falls back to the system font, and on devices whose fallback chain ends at
  /// Noto CJK the Arabic text renders as Chinese glyphs. Bundling removes the
  /// network dependency and matches the fontFamily: 'Cairo' used elsewhere.
  static const fontFamily = 'Cairo';

  static TextTheme _cairoTextTheme(TextTheme base) =>
      base.apply(fontFamily: fontFamily).copyWith(
    headlineLarge:  const TextStyle(fontFamily: fontFamily, fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
    headlineMedium: const TextStyle(fontFamily: fontFamily, fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
    titleLarge:     const TextStyle(fontFamily: fontFamily, fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
    titleMedium:    const TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    bodyLarge:      const TextStyle(fontFamily: fontFamily, fontSize: 15, color: AppColors.textPrimary),
    bodyMedium:     const TextStyle(fontFamily: fontFamily, fontSize: 14, color: AppColors.textSecondary),
    labelLarge:     const TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w600),
  );

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.light(
        primary:   AppColors.primary,
        secondary: AppColors.accent,
        surface:   AppColors.surface,
        error:     AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: _cairoTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: TextStyle(fontFamily: fontFamily,
            fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.textHint),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: const Color(0x1F1B2E6E),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(fontFamily: fontFamily, fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary);
          }
          return TextStyle(fontFamily: fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(color: AppColors.textSecondary, size: 24);
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 68,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceAlt,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: TextStyle(fontFamily: fontFamily, fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
