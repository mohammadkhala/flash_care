class AppConstants {
  static const String appName = 'نبض';
  // static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android emulator
  // static const String baseUrl = 'http://192.168.1.9:8000/api'; // Physical device
  static const String baseUrl = 'https://doctor.baitpait.space/api'; // Production

  /// Dialling codes offered at sign-in, as (code, Arabic name, flag).
  ///
  /// Sign-in used to accept only +970/+972, which locked out therapists and
  /// patients holding any other number. The region comes first, then the
  /// countries with the largest Palestinian diaspora.
  static const List<({String code, String name, String flag})> countries = [
    (code: '+970', name: 'فلسطين',           flag: '🇵🇸'),
    (code: '+972', name: 'إسرائيل',          flag: '🇮🇱'),
    (code: '+962', name: 'الأردن',           flag: '🇯🇴'),
    (code: '+20',  name: 'مصر',              flag: '🇪🇬'),
    (code: '+966', name: 'السعودية',         flag: '🇸🇦'),
    (code: '+971', name: 'الإمارات',         flag: '🇦🇪'),
    (code: '+974', name: 'قطر',              flag: '🇶🇦'),
    (code: '+965', name: 'الكويت',           flag: '🇰🇼'),
    (code: '+973', name: 'البحرين',          flag: '🇧🇭'),
    (code: '+968', name: 'عُمان',            flag: '🇴🇲'),
    (code: '+961', name: 'لبنان',            flag: '🇱🇧'),
    (code: '+963', name: 'سوريا',            flag: '🇸🇾'),
    (code: '+964', name: 'العراق',           flag: '🇮🇶'),
    (code: '+967', name: 'اليمن',            flag: '🇾🇪'),
    (code: '+90',  name: 'تركيا',            flag: '🇹🇷'),
    (code: '+1',   name: 'أمريكا / كندا',    flag: '🇺🇸'),
    (code: '+44',  name: 'بريطانيا',         flag: '🇬🇧'),
    (code: '+49',  name: 'ألمانيا',          flag: '🇩🇪'),
    (code: '+33',  name: 'فرنسا',            flag: '🇫🇷'),
    (code: '+31',  name: 'هولندا',           flag: '🇳🇱'),
    (code: '+32',  name: 'بلجيكا',           flag: '🇧🇪'),
    (code: '+46',  name: 'السويد',           flag: '🇸🇪'),
    (code: '+47',  name: 'النرويج',          flag: '🇳🇴'),
    (code: '+45',  name: 'الدنمارك',         flag: '🇩🇰'),
    (code: '+41',  name: 'سويسرا',           flag: '🇨🇭'),
    (code: '+43',  name: 'النمسا',           flag: '🇦🇹'),
    (code: '+34',  name: 'إسبانيا',          flag: '🇪🇸'),
    (code: '+39',  name: 'إيطاليا',          flag: '🇮🇹'),
    (code: '+30',  name: 'اليونان',          flag: '🇬🇷'),
    (code: '+357', name: 'قبرص',             flag: '🇨🇾'),
    (code: '+56',  name: 'تشيلي',            flag: '🇨🇱'),
    (code: '+55',  name: 'البرازيل',         flag: '🇧🇷'),
    (code: '+61',  name: 'أستراليا',         flag: '🇦🇺'),
    (code: '+212', name: 'المغرب',           flag: '🇲🇦'),
    (code: '+213', name: 'الجزائر',          flag: '🇩🇿'),
    (code: '+216', name: 'تونس',             flag: '🇹🇳'),
    (code: '+218', name: 'ليبيا',            flag: '🇱🇾'),
    (code: '+249', name: 'السودان',          flag: '🇸🇩'),
    (code: '+60',  name: 'ماليزيا',          flag: '🇲🇾'),
    (code: '+62',  name: 'إندونيسيا',        flag: '🇮🇩'),
    (code: '+92',  name: 'باكستان',          flag: '🇵🇰'),
    (code: '+91',  name: 'الهند',            flag: '🇮🇳'),
    (code: '+7',   name: 'روسيا',            flag: '🇷🇺'),
    (code: '+380', name: 'أوكرانيا',         flag: '🇺🇦'),
  ];

  static List<String> get countryCodes =>
      countries.map((c) => c.code).toList(growable: false);

  /// Display label for a dialling code, e.g. "🇵🇸 فلسطين +970".
  static String countryLabel(String code) {
    for (final c in countries) {
      if (c.code == code) return '${c.flag} ${c.name} ${c.code}';
    }
    return code;
  }

  static const String defaultCountryCode = '+972';

  static const int otpLength = 6;
  static const int otpResendSeconds = 60;

  // Agora RTC — replace with your App ID from https://console.agora.io
  static const String agoraAppId = '131d77a1e2c14bb1ba2a50f3c4d8107b';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'current_user';
  static const String fcmTokenKey = 'fcm_token';
}
