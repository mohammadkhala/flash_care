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

  // ── Onboarding ───────────────────────────────────────────────────────
  static String get next         => _t('التالي',   'הבא',   'Next');
  static String get skip         => _t('تخطي',    'דלג',   'Skip');
  static String get getStarted   => _t('ابدأ الآن','התחל', 'Get Started');
  static String get onb1Title    => _t('انضم إلى نبض',
      'הצטרף לנבד',           'Join NABD');
  static String get onb1Desc     => _t(
      'المنصة المتخصصة للأخصائيين في العلاج الطبيعي والوظيفي في فلسطين',
      'הפלטפורמה המתמחה לפיזיותרפיסטים ומרפאים בעיסוק בפלסטין',
      'The dedicated platform for physical & occupational therapists in Palestine');
  static String get onb2Title    => _t('أدر مواعيدك بكفاءة',
      'נהל את הפגישות שלך ביעילות', 'Manage Appointments Efficiently');
  static String get onb2Desc     => _t(
      'جدول دوام مرن وإدارة المواعيد الحضورية والأونلاين من مكان واحد',
      'לוח זמנים גמיש וניהול פגישות פנים אל פנים ואונליין ממקום אחד',
      'Flexible schedule & manage in-person and online sessions from one place');
  static String get onb3Title    => _t('تواصل مع مرضاك',
      'תתקשר עם המטופלים שלך', 'Connect with Your Patients');
  static String get onb3Desc     => _t(
      'رسائل، مكالمات فيديو، وبرامج منزلية متكاملة لمتابعة مرضاك',
      'הודעות, שיחות וידאו ותוכניות ביתיות מקיפות למעקב אחר המטופלים שלך',
      'Messages, video calls & comprehensive home programs to follow up with patients');
  static String get onb4Title    => _t('طور حضورك المهني',
      'פתח את הנוכחות המקצועית שלך', 'Grow Your Professional Presence');
  static String get onb4Desc     => _t(
      'شارك مقالاتك ومقاطعك التعليمية وكن مرجعاً موثوقاً في مجتمعك',
      'שתף מאמרים ווידאו חינוכי והפוך למוקד אמין בקהילה שלך',
      'Share articles & educational videos and become a trusted reference in your community');

  // ── Auth pages ───────────────────────────────────────────────────────
  static String get loginTitle    => _t('تسجيل الدخول',    'כניסה',          'Sign In');
  static String get registerTitle => _t('إنشاء حساب جديد', 'צור חשבון חדש',  'Create Account');
  static String get welcomeBack   => _t('أهلاً بعودتك 👋', 'ברוך שובך 👋',   'Welcome Back 👋');
  static String get enterPhonePass => _t('أدخل رقم هاتفك وكلمة المرور',
      'הזן מספר טלפון וסיסמה', 'Enter your phone number and password');
  static String get phoneLabel    => _t('رقم الهاتف',  'מספר טלפון', 'Phone Number');
  static String get passwordLabel => _t('كلمة المرور', 'סיסמה',      'Password');
  static String get signIn        => _t('دخول',        'כניסה',      'Sign In');
  static String get noAccount     => _t('ليس لديك حساب؟ إنشاء حساب جديد',
      '?אין חשבון? צור חשבון חדש', 'No account? Create a new one');
  static String get welcomeHere   => _t('مرحباً بك 👋', 'ברוך הבא 👋', 'Welcome 👋');
  static String get enterPhoneOtp => _t(
      'أدخل رقم هاتفك لاستلام رمز التحقق عبر واتساب',
      'הזן מספר טלפון לקבלת קוד אימות בוואטסאפ',
      'Enter your phone number to receive a WhatsApp verification code');
  static String get sendOtp       => _t('إرسال رمز التحقق', 'שלח קוד',    'Send Code');
  static String get haveAccount   => _t('لديك حساب بالفعل؟ تسجيل الدخول',
      '?יש לך חשבון? היכנס', 'Have an account? Sign in');
  static String get termsConsent  => _t(
      'بالمتابعة توافق على شروط الاستخدام وسياسة الخصوصية',
      'בהמשך אתה מסכים לתנאי השימוש ומדיניות הפרטיות',
      'By continuing you agree to our Terms & Privacy Policy');
  static String get otpTitle      => _t('التحقق من الهاتف','אימות מספר הטלפון','Phone Verification');
  static String get otpSentTo     => _t('أرسلنا رمز التحقق إلى',
      'שלחנו קוד אימות למספר', 'We sent a verification code to');
  static String get viaWhatsapp   => _t('عبر واتساب',    'דרך ווטסאפ',  'via WhatsApp');
  static String get verifyButton  => _t('تحقق',          'אמת',         'Verify');
  static String get resendOtp     => _t('إعادة إرسال الرمز','שלח מחדש', 'Resend Code');
  static String get appTagline    => _t('رعاية صحية متكاملة', 'בריאות מקיפה', 'Comprehensive Healthcare');
  static String get appSubtag     => _t('سجّل وأدر ممارستك العلاجية',
      'הירשם ונהל את הפרקטיקה הטיפולית שלך', 'Register & manage your therapy practice');

  // ── Navigation ──────────────────────────────────────────────────────
  static String get home         => _t('الرئيسية',   'ראשי',         'Home');
  static String get appointments => _t('المواعيد',   'פגישות',       'Appointments');
  static String get messages     => _t('الرسائل',    'הודעות',       'Messages');
  static String get reels        => _t('الريلز',     'ריילז',        'Reels');
  static String get programs     => _t('البرامج',    'תוכניות',      'Programs');
  static String get myProfile    => _t('ملفي',       'הפרופיל שלי',  'My Profile');

  // ── Profile page ────────────────────────────────────────────────────
  static String get language        => _t('اللغة',            'שפה',                   'Language');
  static String get logout          => _t('تسجيل الخروج',     'התנתקות',               'Logout');
  static String get deleteAccount   => _t('حذف الحساب نهائياً','מחק חשבון לצמיתות',    'Delete Account');
  static String get termsOfUse      => _t('شروط الاستخدام',   'תנאי שימוש',            'Terms of Use');
  static String get privacyPolicy   => _t('سياسة الخصوصية',  'מדיניות פרטיות',        'Privacy Policy');
  static String get notifications   => _t('الإشعارات',        'התראות',                'Notifications');
  static String get schedule        => _t('إدارة جدول الدوام','ניהול לוח זמנים',       'Schedule');
  static String get statistics      => _t('الإحصائيات التفصيلية','סטטיסטיקות מפורטות','Detailed Statistics');
  static String get articles        => _t('مقالاتي التثقيفية','המאמרים שלי',           'My Articles');
  static String get personalBio     => _t('نبذة شخصية',       'קצת עליי',              'About Me');
  static String get basicInfo       => _t('المعلومات الأساسية','מידע בסיסי',            'Basic Info');
  static String get specializations => _t('التخصصات',         'התמחויות',              'Specializations');
  static String get languages       => _t('اللغات',            'שפות',                  'Languages');
  static String get education       => _t('المؤهلات العلمية',  'השכלה',                 'Education');
  static String get pages           => _t('الصفحات',           'דפים',                  'Pages');
  static String get city            => _t('المدينة',           'עיר',                   'City');
  static String get degree          => _t('الدرجة العلمية',   'תואר אקדמי',            'Degree');
  static String get yearsExp        => _t('سنوات الخبرة',      'שנות ניסיון',           'Years of Experience');
  static String get gender          => _t('الجنس',             'מין',                   'Gender');
  static String get phone           => _t('الهاتف',            'טלפון',                 'Phone');
  static String get verified        => _t('موثق',              'מאומת',                 'Verified');

  // ── Appointments page ────────────────────────────────────────────────
  static String get allAppointments => _t('كل المواعيد',    'כל הפגישות',  'All');
  static String get upcoming        => _t('قادمة',           'קרובות',      'Upcoming');
  static String get completed       => _t('مكتملة',          'הושלמו',      'Completed');
  static String get cancelled       => _t('ملغاة',           'בוטלו',       'Cancelled');
  static String get confirmed       => _t('مؤكد',            'מאושר',       'Confirmed');
  static String get pending         => _t('معلق',            'ממתין',       'Pending');
  static String get noAppointments  => _t('لا توجد مواعيد', 'אין פגישות',  'No appointments');

  // ── Session types ─────────────────────────────────────────────────────
  static String get online   => _t('أونلاين',  'אונליין',     'Online');
  static String get inPerson => _t('حضوري',    'פנים אל פנים','In Person');
  static String get perSession => _t('للجلسة', 'לפגישה',      'Per session');
  static String get goodMorning   => _t('صباح الخير',  'בוקר טוב',      'Good Morning');
  static String get goodAfternoon => _t('مساء الخير',  'צהריים טובים',  'Good Afternoon');
  static String get goodEvening   => _t('مساء النور',  'ערב טוב',       'Good Evening');
  static String get totalPatients => _t('المرضى',       'מטופלים',       'Patients');
  static String get totalReviews  => _t('التقييمات',   'ביקורות',       'Reviews');
  static String get reelsSection  => _t('ريلز العلاج الطبيعي','ריילז פיזיותרפיה','Physio Reels');

  // ── Messages ─────────────────────────────────────────────────────────
  static String get typeMessage  => _t('اكتب رسالة...', '...כתוב הודעה', 'Type a message...');
  static String get callAudio    => _t('مكالمة صوتية',  'שיחה קולית',   'Audio Call');
  static String get callVideo    => _t('مكالمة فيديو',   'שיחת וידאו',   'Video Call');

  // ── Home screen ──────────────────────────────────────────────────────
  static String get todayAppointments   => _t('مواعيد اليوم',        'פגישות היום',     'Today\'s Appointments');
  static String get noAppointmentsToday => _t('لا توجد مواعيد اليوم','אין פגישות היום', 'No appointments today');
  static String get seeAll              => _t('عرض الكل',             'הצג הכל',         'See All');
  static String get allLabel            => _t('الكل',                 'הכל',             'All');
  static String get nextAppointment     => _t('الموعد القادم',        'הפגישה הבאה',     'Next Appointment');
  static String get quickActions        => _t('الإجراءات السريعة',    'פעולות מהירות',   'Quick Actions');
  static String get assessmentTools     => _t('أدوات التقييم',        'כלי הערכה',       'Assessment Tools');
  static String get waitingStatus       => _t('انتظار',               'ממתין',           'Waiting');
  static String get confirmedPlural     => _t('مؤكدة',                'מאושרות',         'Confirmed');
  static String get completedPlural     => _t('مكتملة',               'הושלמו',          'Completed');
  static String get cancelledPlural     => _t('ملغية',                'בוטלו',           'Cancelled');
  static String get myArticles          => _t('المقالات',             'המאמרים',         'Articles');
  static String get myReels             => _t('الريلز',               'ריילז',           'Reels');
  static String get myStatistics        => _t('الإحصائيات',           'סטטיסטיקות',      'Statistics');
  static String get myPrograms          => _t('البرامج',              'תוכניות',         'Programs');

  // ── Messages / Conversations ─────────────────────────────────────────
  static String get newConversation   => _t('محادثة جديدة',                'שיחה חדשה',           'New Chat');
  static String get noConversations   => _t('لا توجد محادثات',             'אין שיחות',           'No conversations');
  static String get conversationsHint => _t('ستظهر محادثاتك مع المرضى هنا','שיחות עם מטופלים יופיעו כאן','Chats with patients will appear here');
  static String get selectPatient     => _t('اختر مريضاً',                  'בחר מטופל',           'Select a patient');

  // ── Common ───────────────────────────────────────────────────────────
  static String get save    => _t('حفظ',    'שמור',    'Save');
  static String get cancel  => _t('إلغاء',  'ביטול',   'Cancel');
  static String get back    => _t('رجوع',   'חזרה',    'Back');
  static String get confirm => _t('تأكيد',  'אישור',   'Confirm');
  static String get loading => _t('جاري التحميل...', 'טוען...', 'Loading...');
  static String get error   => _t('حدث خطأ', 'אירעה שגיאה', 'An error occurred');
  static String get retry   => _t('إعادة المحاولة', 'נסה שוב', 'Retry');
  static String get yes     => _t('نعم',   'כן',  'Yes');
  static String get no      => _t('لا',    'לא',  'No');
  static String get delete  => _t('حذف',   'מחק', 'Delete');
  static String get edit    => _t('تعديل', 'ערוך', 'Edit');
  static String get search  => _t('بحث',   'חיפוש', 'Search');
  static String get male    => _t('ذكر',   'זכר',    'Male');
  static String get female  => _t('أنثى',  'נקבה',   'Female');
}
