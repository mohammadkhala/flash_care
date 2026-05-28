class AppConstants {
  static const String appName = 'نبض';
  // static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android emulator
  static const String baseUrl = 'http://192.168.1.3:8000/api'; // Physical device
  // static const String baseUrl = 'http://localhost:8000/api'; // iOS simulator
  // static const String baseUrl = 'https://api.nabdh.ps/api'; // Production

  static const List<String> countryCodes = ['+970', '+972'];
  static const String defaultCountryCode = '+972';

  static const int otpLength = 6;
  static const int otpResendSeconds = 60;

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'current_user';
  static const String fcmTokenKey = 'fcm_token';
}
