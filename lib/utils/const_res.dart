class ConstRes {
  ///------------------------ Backend urls and key ------------------------///

  static const String base = 'https://doctor.baitpait.space/';
  static const String baseURL = '${base}api/';
  static const String itemBaseURL = '${base}public/storage/';
  static const String privacyPolicy = '${base}privacypolicy';
  static const String termsOfUser = '${base}termsOfUse';
  static const String apiKey = '123';

  ///------------------------ Notification token ------------------------///

  static const String subscribeTopic = 'doctor';

  ///------------------------ Agora app Id ------------------------///

  static const String agoraAppId = "ENTER AGORA APP ID";
}

// App Name
const String appName = 'Flash Care';
const String subAppName = 'تطبيق الأخصائي';

// App Default Language only use This code :-  ('ar', 'da','nl','en','fr','de','el','hi','id','it','ja','ko','nb','pl','pt','ru','zh','es','th','tr','vi')
const appLanguageCode = 'ar';

// For Phone Number field
const countryName = 'India';
const countryCode = 'IN';
const phoneCode = '+91';

///------------------------ Image quality ------------------------///
const int imageQuality = 40;
const double maxWidth = 720;
const double maxHeight = 720;

//  Slot Limit
const int maxSlotLimit = 10;

// pagination count
const paginationLimit = 10;

List<String> reportReason = [
  'انتهاك حقوق النشر',
  'خطاب الكراهية',
  'التحرش أو التنمر',
  'العنف أو التهديد',
  'محتوى إباحي أو جنسي',
  'إرهاب أو محتوى متطرف',
  'احتيال أو نصب',
  'بريد مزعج',
  'انتحال الهوية',
  'معلومات مضللة'
];