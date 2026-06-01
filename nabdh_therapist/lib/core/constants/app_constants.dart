class AppConstants {
  static const String appName = 'نبض';
  // static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android emulator
  // static const String baseUrl = 'http://192.168.1.3:8000/api'; // Physical device
  static const String baseUrl = 'https://doctor.baitpait.space/api'; // Production

  static const List<String> countryCodes = ['+970', '+972'];
  static const String defaultCountryCode = '+972';

  static const int otpLength = 6;
  static const int otpResendSeconds = 60;

  // Agora RTC — replace with your App ID from https://console.agora.io
  static const String agoraAppId = 'd4733bd9cdc7460183a25cdcbb6f577d';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'current_user';
  static const String fcmTokenKey = 'fcm_token';
}
