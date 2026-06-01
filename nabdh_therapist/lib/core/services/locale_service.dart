import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages app locale (AR / HE / EN) with persistence.
class LocaleService extends ChangeNotifier {
  static const _key = 'app_locale';
  static final LocaleService instance = LocaleService._();
  LocaleService._();

  Locale _locale = const Locale('ar');
  Locale get locale => _locale;

  static const supportedLocales = [
    Locale('ar'),
    Locale('he'),
    Locale('en'),
  ];

  static const localeNames = {
    'ar': 'العربية',
    'he': 'עברית',
    'en': 'English',
  };

  static const localeFlags = {
    'ar': '🇵🇸',
    'he': '🇮🇱',
    'en': '🇬🇧',
  };

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key) ?? 'ar';
    _locale = Locale(saved);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
    notifyListeners();
  }
}
