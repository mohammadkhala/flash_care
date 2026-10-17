# توثيق مشروع نبض (NABD / Flash Care)

آخر تحديث: **2026-10-13** — الكود والسيرفر على `master` @ `88266b9` (الباك إند).

## هيكل المشروع

```
flash_care/
├── nabdh_backend/      ← Laravel — لوحة الأدمن + API
├── nabdh_patient/      ← Flutter — تطبيق المريض
├── nabdh_therapist/    ← Flutter — تطبيق الطبيب/الأخصائي
└── docs/               ← هذا المجلد
```

## الروابط

| البيئة | الرابط |
|--------|--------|
| الإنتاج | https://doctor.baitpait.space |
| لوحة الأدمن | https://doctor.baitpait.space/admin/login |
| API | https://doctor.baitpait.space/api |
| GitHub | https://github.com/mohammadkhala/flash_care.git |
| مسار السيرفر | `/home/sarfesak/public_html/doctor` |

## الفرع النشط

استخدم **`master`** — أحدث من `main`.

```bash
# محلياً
git pull origin master

# على السيرفر: لا تستخدم git pull وحده — انظر SERVER_DEPLOY.md
```

## فهرس التوثيق

| الملف | المحتوى |
|-------|---------|
| [CHANGELOG.md](./CHANGELOG.md) | تقرير آخر سحب + سجل الإصلاحات |
| [SERVER_DEPLOY.md](./SERVER_DEPLOY.md) | أوامر النشر على السيرفر |
| [MOBILE_BUILD.md](./MOBILE_BUILD.md) | بناء APK وتشغيل المحاكي |
| [ENV_AND_NOTIFICATIONS.md](./ENV_AND_NOTIFICATIONS.md) | `.env` و Firebase و FCM و آلية المكالمات |
| [CALLS_TESTING.md](./CALLS_TESTING.md) | خطة تجربة المكالمات + تشخيص المشاكل |
| [FINANCE.md](./FINANCE.md) | النظام المالي عند الأخصائي + «فواتيري» عند المريض |
| [REPORTS.md](./REPORTS.md) | ملف المريض: قوالب التقييم (لوحة التحكم) + تقارير الأخصائي PDF |

## الحالة الحالية

| البند | الحالة |
|--------|--------|
| كود محلي | `master` @ `ea9a166` ✅ |
| سيرفر الإنتاج | نُشر 2026-10-17 (`ea9a166`) ✅ |
| Firebase | `nabd-3e72e` — مفتاح جديد 2026-10-13 (القديم كان ملغى)، إشعار تجريبي للجوالين قُبل ✅ |
| Agora | App ID يطابق التطبيقين — توكن السيرفر أُصلح 2026-10-17 (`9ad7bbc`)، وAgora يقبله فعلياً (انضمام عميلين) ✅ |
| واتساب (WaSender) | المفتاح صالح، الجلسة متصلة، إصلاح +970/+972 منشور ✅ |
| وضع السيرفر | `APP_ENV=production` · `APP_DEBUG=false` ✅ |
| Migration الأخيرة | `allow_cv_in_therapist_documents` DONE ✅ |
| وثائق الأخصائي | تخزين خاص (المدير / صاحبها فقط)، السيرة الذاتية تُرفع الآن ✅ — APK الأخصائي 16:21 ⏳ تجربة |
| **تقارير التقييم** | منشور على السيرفر + لوحة التحكم ✅ — APK 16:06 ⏳ تجربة الشاشات — [REPORTS.md](./REPORTS.md) |
| APK على سطح المكتب | الأخصائي 2026-10-17 16:21 (`ea9a166`) · المريض 16:35 (`d70a4cf`) — بانتظار الإرسال والتجربة ⏳ |
| **النظام المالي** | منشور + 7 فواتير للجلسات القديمة — ⏳ تجربة الشاشات — [FINANCE.md](./FINANCE.md) |
| **المكالمات (رنين + Agora)** | ⏳ **في انتظار تجربة المستخدم** — [CALLS_TESTING.md](./CALLS_TESTING.md) |

## تسجيل دخول الأدمن

- الرابط: `/admin/login`
- الهاتف: بدون مفتاح الدولة (مثال: `599000000`)
- بعد إعادة تعيين كلمة المرور عبر tinker على السيرفر إن لزم

## ملاحظات تشغيل مهمة

1. على السيرفر: `fetch` + `checkout nabdh_backend` + `rsync` ثم `migrate` + `cache`. لا تعتمد على `git pull` وحده.
2. `FIREBASE_PROJECT_ID` يجب أن يكون `nabd-3e72e` (بدون حرف **h**). القيمة `nabdh-3e72e` تسبب 403.
3. بعد تثبيت أي APK جديد: فتح التطبيق مرة والحساب مسجّل دخول يكفي لتحديث توكن الإشعارات (لا حاجة لحسابات جديدة).
4. إذا توقفت الإشعارات والرنين معاً وظهر في السجل `Invalid JWT Signature`: مفتاح Firebase ملغى — الخطوات في [ENV_AND_NOTIFICATIONS.md](./ENV_AND_NOTIFICATIONS.md).
