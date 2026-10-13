# إعدادات البيئة والإشعارات (FCM)

## متغيرات `.env` المطلوبة للمشروع

| المتغير | الوصف | مطلوب |
|---------|--------|-------|
| `APP_URL` | رابط السيرفر | ✅ |
| `DB_*` | قاعدة البيانات | ✅ |
| `WASENDER_API_KEY` | OTP عبر واتساب | ✅ |
| `WASENDER_SESSION` | جلسة WaSender | ✅ |
| `WASENDER_PHONE` | رقم المرسل | ✅ |
| `FIREBASE_PROJECT_ID` | مشروع Firebase | ✅ |
| `FIREBASE_CREDENTIALS` | مسار ملف Service Account | ✅ |
| `AGORA_APP_ID` | المكالمات الصوتية والفيديو — يجب أن يطابق `agoraAppId` في `app_constants.dart` للتطبيقين | ✅ |
| `AGORA_APP_CERTIFICATE` | شهادة Agora (توليد التوكن) | ✅ |
| `FRONTEND_URL` | — | ❌ غير مستخدم في الباكند |

## تطابق Firebase (مهم جداً)

يجب أن يكون **نفس** `project_id` في ثلاثة أماكن:

| المكان | القيمة الصحيحة |
|--------|----------------|
| `.env` → `FIREBASE_PROJECT_ID` | `nabd-3e72e` |
| `storage/app/firebase-credentials.json` → `project_id` | `nabd-3e72e` |
| `android/app/google-services.json` (كلا التطبيقين) | `nabd-3e72e` |

### خطأ شائع

```env
FIREBASE_PROJECT_ID=nabdh-3e72e   # ❌ بحرف h — يسبب 403 Forbidden
```

```env
FIREBASE_PROJECT_ID=nabd-3e72e    # ✅
```

بعد التعديل:

```bash
php artisan config:clear
php artisan cache:clear
php artisan config:cache
```

---

## التحقق من ملف Firebase على السيرفر

```bash
cd /home/sarfesak/public_html/doctor

# الملف موجود؟
ls -la storage/app/firebase-credentials.json

# JSON صالح؟
php -r 'json_decode(file_get_contents("storage/app/firebase-credentials.json")); echo json_last_error()===JSON_ERROR_NONE ? "OK\n" : "INVALID\n";'

# project_id متطابق؟
grep FIREBASE_PROJECT_ID .env
php -r '$c=json_decode(file_get_contents("storage/app/firebase-credentials.json"),true); echo "credentials: ".$c["project_id"].PHP_EOL;'

# رابط storage
ls -la public/storage
php artisan storage:link   # إن كان ناقصاً
```

---

## فحص الإشعارات (FCM)

### 1) مستخدمون لديهم توكن؟

```bash
php artisan tinker --execute='echo \App\Models\User::whereNotNull("fcm_token")->count();'
```

### 2) إرسال تجريبي

```bash
php artisan tinker --execute='$u = \App\Models\User::find(36); if (!$u || !$u->fcm_token) { echo "no token\n"; exit; } app(\App\Services\FcmService::class)->send($u, "اختبار", "إشعار تجريبي", ["type"=>"test"], "test"); echo "sent\n";'
```

> استخدم علامات اقتباس **مفردة** `'...'` حول الأمر في الشيل.

### 3) مراقبة الأخطاء

```bash
tail -f storage/logs/laravel.log
grep "FCM push failed" storage/logs/laravel.log | tail -n 5
```

### 4) من لوحة الأدمن

`الإعدادات` → `إرسال إشعار` → اختر الدور (patient / therapist / all)

---

## أخطاء FCM الشائعة

| الخطأ | السبب | الحل |
|-------|--------|------|
| `403 Permission denied on project nabdh-3e72e` | `FIREBASE_PROJECT_ID` خاطئ | غيّر إلى `nabd-3e72e` |
| `404 Requested entity was not found` | توكن FCM قديم/منتهي | مسح التوكن + إعادة تسجيل دخول من التطبيق |
| `users with token: 0` | التطبيق لم يُرسل التوكن | تسجيل دخول + صلاحيات إشعارات |
| إشعار في التطبيق فقط بدون Push | توكن قديم أو صلاحيات الجوال | إعادة تسجيل دخول |

### مسح توكن قديم لمستخدم

```bash
php artisan tinker --execute='\App\Models\User::where("id", 2)->update(["fcm_token" => null]); echo "cleared\n";'
```

ثم من الجوال: خروج → دخول → السماح بالإشعارات.

---

## كيف يعمل FCM في المشروع

1. التطبيق يحصل على توكن من Firebase عند التشغيل
2. بعد تسجيل الدخول: `POST /api/auth/fcm-token`
3. السيرفر يخزّن التوكن في `users.fcm_token`
4. عند حدث (رسالة، موعد، إلخ): `FcmService` يرسل عبر FCM v1 API
5. الإشعار يُحفظ أيضاً في جدول `push_notifications` (يظهر داخل التطبيق)

## المكالمات (Agora + رنين)

الصوت والصورة عبر **Agora**، والرنين عبر شاشة مكالمة نظامية (`flutter_callkit_incoming`).

1. المتصل يفتح شاشة المكالمة → `POST /api/calls/initiate` → يدخل قناة Agora ويسمع نغمة الانتظار
2. السيرفر يرسل للطرف الآخر FCM **data-only** بأولوية عالية (`type=incoming_call`، صلاحية 45 ثانية) عبر `FcmService::sendCall`
3. جوال المستقبل يُظهر شاشة رنين كاملة بنغمة الهاتف — حتى والتطبيق مغلق أو الشاشة مقفلة
4. «رد» → يفتح التطبيق على شاشة المكالمة → `POST /calls/{channel}/answer` → يدخل نفس القناة
5. «رفض» أو إنهاء أو عدم الرد خلال 45 ثانية → `POST /calls/{channel}/status` → السيرفر يرسل `call_ended` لإيقاف الرنين، وفي حالة عدم الرد إشعار «مكالمة فائتة»

| القناة | الاستخدام |
|--------|-----------|
| `nabd-conv-{id}` | مكالمة من المحادثة (مريض↔أخصائي أو أخصائي↔أخصائي) |
| `nabd-session-{id}` | جلسة فيديو لموعد |

- توكن Agora: `POST /api/agora/token` — يُرفض (403) إن لم يكن المستخدم طرفاً في المحادثة/الموعد
- مكالمات الإشعارات القديمة (`incoming_call` المحفوظة في الجدول) تُتجاهل في التطبيق

### إعدادات الجوال المطلوبة للرنين والتطبيق مغلق

تظهر للمستخدم رسالة «حتى تصلك المكالمات وترنّ» عند أول دخول للرئيسية (ومرة يومياً حتى يكملها)، ويمكن فتحها من **الملف الشخصي ← إعدادات المكالمات**. كل زر يفتح الإعداد مباشرة:

الإشعارات · الميكروفون والكاميرا · شاشة المكالمة الكاملة (أندرويد 14+) · العرض فوق التطبيقات · إيقاف توفير البطارية · التشغيل التلقائي (شاومي/أوبو/ريلمي/فيفو/هواوي/أونر/ون بلس فقط)

## Cron للتذكيرات التلقائية

```bash
php artisan schedule:list
```

| الأمر | التوقيت |
|-------|---------|
| `reminders:sessions` | كل 30 دقيقة |
| `reminders:programs` | يومياً 08:00 |

---

## إعدادات الأمان على السيرفر

```env
APP_ENV=production
APP_DEBUG=false
```

## آخر تحقق ناجح (السيرفر)

- **التاريخ:** 2026-08-17
- **الأمر:** `php artisan tinker --execute="echo config('services.firebase.project_id');"`
- **النتيجة:** `nabd-3e72e` ✅
- **ملف credentials:** موجود وصالح JSON
- **رابط:** `public/storage` → `storage/app/public`
