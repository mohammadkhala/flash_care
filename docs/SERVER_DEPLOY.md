# نشر الباكند على السيرفر

## المسار

```
/home/sarfesak/public_html/doctor
```

## أوامر كاملة (انسخها كما هي على السيرفر)

```bash
cd /home/sarfesak/public_html/doctor

git config --global --add safe.directory /home/sarfesak/public_html/doctor
git fetch origin master
git checkout origin/master -- nabdh_backend
rsync -av --exclude='.env' --exclude='.git' --exclude='storage/' --exclude='vendor/' nabdh_backend/ ./
composer install --no-dev --optimize-autoloader
php artisan migrate --force
php artisan route:clear && php artisan view:clear
php artisan config:cache && php artisan route:cache && php artisan view:cache
```

إذا طلب GitHub اسم مستخدم/كلمة مرور عند `fetch`: استخدم Personal Access Token ككلمة مرور (وليس كلمة مرور الحساب).

إذا سأل Composer `Continue as root/super user` أجب `yes`.

## سحب التحديثات من GitHub (تفصيل)

```bash
cd /home/sarfesak/public_html/doctor

git config --global --add safe.directory /home/sarfesak/public_html/doctor
git fetch origin master
git checkout origin/master -- nabdh_backend
rsync -av --exclude='.env' --exclude='.git' --exclude='storage/' --exclude='vendor/' nabdh_backend/ ./
```

## بعد السحب (مهم)

```bash
composer install --no-dev --optimize-autoloader
php artisan migrate --force
php artisan route:clear && php artisan view:clear
php artisan config:cache && php artisan route:cache && php artisan view:cache
```

## ملفات محمية (لا تُستبدل بالسحب)

- `.env`
- `storage/`
- `vendor/` (يُحدَّث عبر `composer` فقط)

## إعدادات `.env` الموصى بها على السيرفر

```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://doctor.baitpait.space

FIREBASE_PROJECT_ID=nabd-3e72e
FIREBASE_CREDENTIALS=storage/app/firebase-credentials.json

AGORA_APP_ID=...
AGORA_APP_CERTIFICATE=...

WASENDER_API_KEY=...
WASENDER_SESSION=baitpait
WASENDER_PHONE=+970599814754
```

> **تنبيه:** `FIREBASE_PROJECT_ID` يجب أن يطابق `project_id` داخل `firebase-credentials.json` و `google-services.json` في التطبيقات (`nabd-3e72e` — بدون حرف h).

## التحقق بعد النشر

بعد الخروج من الشيل أعد الدخول ثم:

```bash
cd /home/sarfesak/public_html/doctor
php artisan tinker --execute="echo config('services.firebase.project_id');"
php artisan migrate:status
```

المتوقع: `nabd-3e72e`

## Cron (تذكيرات المواعيد والبرامج)

```cron
* * * * * cd /home/sarfesak/public_html/doctor && php artisan schedule:run >> /dev/null 2>&1
```

التحقق:

```bash
php artisan schedule:list
crontab -l
```

## مسار سريع (سحب فقط)

```bash
cd /home/sarfesak/public_html/doctor && git pull origin master
```

> يعمل فقط إذا كان المجلد git repo كامل. على السيرفر الحالي يُفضَّل workflow الـ `fetch + checkout + rsync` أعلاه.

## آخر نشر ناجح

- **التاريخ:** 2026-08-17
- **الفرع:** `master` @ `cf00c30`
- **المسار:** `/home/sarfesak/public_html/doctor`
- **Migration:** `2026_08_17_000001_add_media_name_to_program_exercises` → DONE
- **Firebase:** `nabd-3e72e` (تم التحقق عبر tinker)
- **محمي ولم يُمس:** `.env` / `storage/` / `vendor/`

ما دخل في هذا النشر:

- خريطة المريض وإظهار الأطباء
- اختيار موقع في لوحة الأدمن
- مستندات التحقق للأخصائي
- إشعارات في الخلفية + حذف الإشعارات
- أكواد دول متعددة للتسجيل
- إصلاح رفع وسائط البرامج المنزلية
