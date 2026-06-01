import '../services/locale_service.dart';

/// Central translation class.
/// Usage: S.home  →  'الرئيسية' | 'ראשי' | 'Home'
class S {
  S._();

  static String get _lang => LocaleService.instance.locale.languageCode;

  static String _t(String ar, String he, String en) {
    switch (_lang) {
      case 'he': return he;
      case 'en': return en;
      default:   return ar;
    }
  }

  // ── Navigation ──────────────────────────────────────────────────────
  static String get home         => _t('الرئيسية',   'ראשי',         'Home');
  static String get therapists   => _t('الأخصائيون', 'מטפלים',       'Therapists');
  static String get appointments => _t('مواعيدي',    'הפגישות שלי',  'Appointments');
  static String get reels        => _t('ريلز',        'ריילז',        'Reels');
  static String get messages     => _t('الرسائل',    'הודעות',       'Messages');
  static String get myAccount    => _t('حسابي',      'החשבון שלי',   'My Account');

  // ── Onboarding ───────────────────────────────────────────────────────
  static String get next            => _t('التالي',  'הבא',    'Next');
  static String get skip            => _t('تخطي',   'דלג',    'Skip');
  static String get getStarted      => _t('ابدأ الآن','התחל',  'Get Started');
  // Slide 1
  static String get onb1Title       => _t('مرحباً في نبض',
      'ברוך הבא לנבד',         'Welcome to NABD');
  static String get onb1Desc        => _t(
      'منصة العلاج الطبيعي والوظيفي المتخصصة في فلسطين',
      'פלטפורמת הפיזיותרפיה והריפוי בעיסוק בפלסטין',
      'Palestine\'s dedicated physical & occupational therapy platform');
  // Slide 2
  static String get onb2Title       => _t('ابحث عن أخصائي',
      'מצא מטפל',              'Find a Therapist');
  static String get onb2Desc        => _t(
      'اعثر على أخصائي علاج طبيعي قريب منك وتعرّف على تخصصاته وتقييماته',
      'מצא מטפל קרוב אליך, ראה התמחויות ודירוגים',
      'Find a nearby physio therapist and explore their specializations & ratings');
  // Slide 3
  static String get onb3Title       => _t('احجز موعدك بسهولة',
      'הזמן פגישה בקלות',     'Book Sessions Easily');
  static String get onb3Desc        => _t(
      'احجز جلسات حضورية أو عن بُعد في الوقت الذي يناسبك',
      'הזמן פגישות פנים אל פנים או אונליין בכל שעה שנוחה לך',
      'Book in-person or online sessions at any time that suits you');
  // Slide 4
  static String get onb4Title       => _t('تابع تعافيك',
      'עקוב אחרי ההתאוששות שלך', 'Track Your Recovery');
  static String get onb4Desc        => _t(
      'برامج منزلية وأهداف علاجية لمتابعة تقدمك اليومي نحو الشفاء',
      'תוכניות ביתיות ויעדים טיפוליים למעקב אחר התקדמותך היומית',
      'Home programs & therapeutic goals to monitor your daily recovery progress');

  // ── Auth pages ───────────────────────────────────────────────────────
  static String get loginTitle      => _t('تسجيل الدخول',    'כניסה',           'Sign In');
  static String get registerTitle   => _t('إنشاء حساب جديد', 'צור חשבון חדש',   'Create Account');
  static String get welcomeBack     => _t('أهلاً بعودتك 👋', 'ברוך שובך 👋',    'Welcome Back 👋');
  static String get enterPhonePass  => _t('أدخل رقم هاتفك وكلمة المرور',
      'הזן מספר טלפון וסיסמה', 'Enter your phone number and password');
  static String get phoneLabel      => _t('رقم الهاتف',   'מספר טלפון',  'Phone Number');
  static String get passwordLabel   => _t('كلمة المرور',  'סיסמה',       'Password');
  static String get signIn          => _t('دخول',         'כניסה',       'Sign In');
  static String get noAccount       => _t('ليس لديك حساب؟ إنشاء حساب جديد',
      '?אין חשבון? צור חשבון חדש', 'No account? Create a new one');
  static String get welcomeHere     => _t('مرحباً بك 👋',  'ברוך הבא 👋', 'Welcome 👋');
  static String get enterPhoneOtp   => _t(
      'أدخل رقم هاتفك لاستلام رمز التحقق عبر واتساب',
      'הזן מספר טלפון לקבלת קוד אימות בוואטסאפ',
      'Enter your phone number to receive a WhatsApp verification code');
  static String get sendOtp         => _t('إرسال رمز التحقق', 'שלח קוד',     'Send Code');
  static String get haveAccount     => _t('لديك حساب بالفعل؟ تسجيل الدخول',
      '?יש לך חשבון? היכנס', 'Have an account? Sign in');
  static String get termsConsent    => _t(
      'بالمتابعة توافق على شروط الاستخدام وسياسة الخصوصية',
      'בהמשך אתה מסכים לתנאי השימוש ומדיניות הפרטיות',
      'By continuing you agree to our Terms & Privacy Policy');
  static String get otpTitle        => _t('التحقق من الهاتف','אימות מספר הטלפון','Phone Verification');
  static String get otpSentTo       => _t('أرسلنا رمز التحقق إلى',
      'שלחנו קוד אימות למספר', 'We sent a verification code to');
  static String get viaWhatsapp     => _t('عبر واتساب',      'דרך ווטסאפ',   'via WhatsApp');
  static String get verifyButton    => _t('تحقق',            'אמת',          'Verify');
  static String get resendOtp       => _t('إعادة إرسال الرمز','שלח מחדש',    'Resend Code');
  static String get appTagline      => _t('رعاية صحية متكاملة', 'בריאות מקיפה', 'Comprehensive Healthcare');
  static String get appSubtag       => _t('احجز مواعيدك وتواصل مع أخصائييك\nمن مكان واحد',
      'הזמן פגישות ותתקשר עם המטפלים שלך ממקום אחד',
      'Book sessions & connect with your therapists in one place');

  // ── Programs & Goals ────────────────────────────────────────────────
  static String get myGoals         => _t('أهدافي',               'המטרות שלי',  'My Goals');
  static String get myProgramsTitle => _t('برامجي',               'התוכניות שלי','My Programs');

  // ── Profile page ────────────────────────────────────────────────────
  static String get myProfile       => _t('ملفي الشخصي',      'הפרופיל שלי',           'My Profile');
  static String get myPrograms      => _t('برامجي',            'התוכניות שלי',          'My Programs');
  static String get myDocuments     => _t('وثائقي الطبية',    'המסמכים הרפואיים שלי',  'My Documents');
  static String get notifications   => _t('الإشعارات',        'התראות',                'Notifications');
  static String get language        => _t('اللغة',             'שפה',                   'Language');
  static String get rateApp         => _t('قيّم التطبيق',     'דרג את האפליקציה',      'Rate App');
  static String get termsOfUse      => _t('شروط الاستخدام',   'תנאי שימוש',            'Terms of Use');
  static String get privacyPolicy   => _t('سياسة الخصوصية',  'מדיניות פרטיות',        'Privacy Policy');
  static String get logout          => _t('تسجيل الخروج',     'התנתקות',               'Logout');
  static String get deleteAccount   => _t('حذف الحساب نهائياً','מחק חשבון לצמיתות',    'Delete Account');
  static String get sessions        => _t('الجلسات',           'פגישות',               'Sessions');
  static String get programs        => _t('البرامج',           'תוכניות',              'Programs');
  static String get howAreYouToday  => _t('كيف حالك اليوم؟',  '?איך אתה מרגיש היום',  'How are you today?');

  // ── Mood labels ─────────────────────────────────────────────────────
  static String get moodBad     => _t('سيء',   'גרוע', 'Bad');
  static String get moodSad     => _t('حزين',  'עצוב', 'Sad');
  static String get moodOkay    => _t('عادي',  'סביר', 'Okay');
  static String get moodGood    => _t('جيد',   'טוב',  'Good');
  static String get moodGreat   => _t('ممتاز', 'מצוין','Great');

  // ── Appointments page ────────────────────────────────────────────────
  static String get allAppointments       => _t('كل المواعيد',        'כל הפגישות',        'All');
  static String get upcoming              => _t('القادمة',             'קרובות',            'Upcoming');
  static String get previous              => _t('السابقة',             'קודמות',            'Previous');
  static String get completed             => _t('مكتملة',              'הושלמו',            'Completed');
  static String get cancelled             => _t('ملغاة',               'בוטלו',             'Cancelled');
  static String get noAppointments        => _t('لا توجد مواعيد',      'אין פגישות',        'No appointments');
  static String get noUpcomingAppts       => _t('لا توجد مواعيد قادمة','אין פגישות קרובות', 'No upcoming appointments');
  static String get noPreviousAppts       => _t('لا توجد مواعيد سابقة','אין פגישות קודמות', 'No previous appointments');
  static String get bookNow               => _t('احجز الآن',           'הזמן עכשיו',        'Book Now');
  static String get confirmed             => _t('مؤكد',                'מאושר',             'Confirmed');
  static String get pending               => _t('قيد الانتظار',        'ממתין',             'Pending');
  static String get statusCompleted       => _t('مكتمل',               'הושלם',             'Completed');
  static String get statusCancelled       => _t('ملغى',                'בוטל',              'Cancelled');

  // ── Therapist list / search ──────────────────────────────────────────
  static String get search            => _t('بحث',              'חיפוש',       'Search');
  static String get searchHint        => _t('ابحث عن أخصائي...','חפש מטפל...', 'Search therapist...');
  static String get nearbyTherapists  => _t('الأخصائيون القريبون','מטפלים קרובים','Nearby Therapists');
  static String get viewProfile       => _t('عرض الملف',         'צפה בפרופיל', 'View Profile');
  static String get online            => _t('أونلاين',            'אונליין',     'Online');
  static String get inPerson          => _t('حضوري',             'פנים אל פנים','In Person');
  static String get yearsExp          => _t('سنوات خبرة',        'שנות ניסיון', 'Years Exp.');
  static String get bookSession       => _t('احجز جلسة',          'הזמן פגישה',  'Book Session');
  static String get review            => _t('مراجعة',             'ביקורת',      'Review');

  // ── Messages ─────────────────────────────────────────────────────────
  static String get typeMessage       => _t('اكتب رسالة...',     '...כתוב הודעה','Type a message...');
  static String get callAudio         => _t('مكالمة صوتية',      'שיחה קולית',  'Audio Call');
  static String get callVideo         => _t('مكالمة فيديو',       'שיחת וידאו',  'Video Call');

  // ── Home screen ──────────────────────────────────────────────────────
  static String get featuredTherapists => _t('أخصائيون مميزون',    'מטפלים מומלצים',       'Featured Therapists');
  static String get nextAppointment    => _t('موعدك القادم',        'הפגישה הבאה שלך',      'Next Appointment');
  static String get seeAll             => _t('عرض الكل',            'הצג הכל',              'See All');
  static String get quickActions       => _t('إجراءات سريعة',       'פעולות מהירות',        'Quick Actions');
  static String get bookAppointment    => _t('احجز موعد',           'הזמן פגישה',           'Book Appointment');
  static String get myProgramsShort    => _t('برامجي',              'התוכניות שלי',         'My Programs');
  static String get assessments        => _t('التقييمات',           'הערכות',               'Assessments');
  static String get reelsPhysio        => _t('ريلز العلاج الطبيعي', 'ריילז פיזיותרפיה',     'Physio Reels');
  static String get goodMorning        => _t('صباح الخير',          'בוקר טוב',             'Good Morning');
  static String get goodAfternoon      => _t('مساء الخير',          'צהריים טובים',         'Good Afternoon');
  static String get goodEvening        => _t('مساء النور',          'ערב טוב',              'Good Evening');

  // ── Filters / Search ─────────────────────────────────────────────────
  static String get filterResults   => _t('تصفية النتائج',  'סינון תוצאות',  'Filter Results');
  static String get specialization  => _t('التخصص',         'התמחות',        'Specialization');
  static String get genderLabel     => _t('الجنس',          'מגדר',          'Gender');
  static String get sessionType     => _t('نوع الجلسة',     'סוג פגישה',     'Session Type');
  static String get all             => _t('الكل',           'הכל',           'All');
  static String get male            => _t('ذكر',            'זכר',           'Male');
  static String get female          => _t('أنثى',           'נקבה',          'Female');
  static String get applyFilter     => _t('تطبيق الفلتر',   'החל סינון',     'Apply Filter');
  static String get noTherapists    => _t('لا يوجد أخصائيون','אין מטפלים',   'No therapists found');
  static String get perSession      => _t('للجلسة',          'לפגישה',        'Per session');
  static String get mapLabel        => _t('خريطة الأخصائيين','מפת מטפלים',   'Therapists Map');

  // ── Notifications ─────────────────────────────────────────────────────
  static String get noNotifications    => _t('لا توجد إشعارات',     'אין התראות',      'No notifications');
  static String get markAllRead        => _t('قراءة الكل',          'סמן הכל כנקרא',  'Mark all read');

  // ── Messages / Conversations ─────────────────────────────────────────
  static String get noConversations    => _t('لا توجد محادثات',           'אין שיחות',          'No conversations');
  static String get selectTherapist    => _t('اختر أخصائياً',             'בחר מטפל',           'Select a therapist');
  static String get conversationsHint  => _t('ستظهر محادثاتك هنا',        'השיחות שלך יופיעו כאן','Your conversations will appear here');

  // ── Common ───────────────────────────────────────────────────────────
  static String get save               => _t('حفظ',    'שמור',    'Save');
  static String get cancel             => _t('إلغاء',  'ביטול',   'Cancel');
  static String get back               => _t('رجوع',   'חזרה',    'Back');
  static String get confirm            => _t('تأكيد',  'אישור',   'Confirm');
  static String get loading            => _t('جاري التحميل...', 'טוען...', 'Loading...');
  static String get error              => _t('حدث خطأ', 'אירעה שגיאה', 'An error occurred');
  static String get retry              => _t('إعادة المحاولة', 'נסה שוב', 'Retry');
  static String get yes                => _t('نعم',   'כן',  'Yes');
  static String get no                 => _t('لا',    'לא',  'No');
  static String get delete             => _t('حذف',   'מחק', 'Delete');
  static String get edit               => _t('تعديل', 'ערוך','Edit');

  static List<String> get moodLabels => [moodBad, moodSad, moodOkay, moodGood, moodGreat];
}
