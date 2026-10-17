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

## نسخة احتياطية قبل أي migration

`mysqldump` يحتاج `--no-defaults` لأن ملف إعدادات root على السيرفر يتجاوز كلمة مرور المشروع (خطأ 1045). الأمر يقرأ بيانات القاعدة من إعدادات Laravel ولا يطبعها:

```bash
cd /home/sarfesak/public_html/doctor
F=storage/app/db-backup-$(date +%Y%m%d)-pre-NAME.sql.gz
php -r '
require "vendor/autoload.php";
$app = require "bootstrap/app.php";
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
$c = config("database.connections.mysql");
putenv("MYSQL_PWD=" . $c["password"]);
passthru(sprintf("mysqldump --no-defaults -h%s -P%s -u%s --single-transaction --no-tablespaces %s | gzip > %s",
  escapeshellarg($c["host"]), escapeshellarg((string)$c["port"]), escapeshellarg($c["username"]),
  escapeshellarg($c["database"]), escapeshellarg($argv[1])), $rc); exit($rc);' "$F"
chown sarfesak:sarfesak "$F" && chmod 600 "$F"
gunzip -c "$F" | grep -c "CREATE TABLE"   # يجب أن يكون > 0
```

النسخ الموجودة (2026-10-17): `db-backup-20261017-pre-finance` · `-pre-reports` · `-pre-letterhead` · `-pre-documents`.

## مجلدات يحتاجها التطبيق (مالكها `sarfesak` — مستخدم الموقع)

| المجلد | الغرض |
|--------|-------|
| `storage/app/private/therapist_docs` | وثائق الأخصائي (خاص — لا يُفتح من الويب) — `chmod 750` |
| `storage/app/mpdf` | ملفات mPDF المؤقتة لتقارير PDF |
| `storage/app/public/clinic_logos`, `expense_receipts` | تُنشأ تلقائياً عند الرفع |

```bash
mkdir -p storage/app/private/therapist_docs storage/app/mpdf
chown -R sarfesak:sarfesak storage/app/private storage/app/mpdf
```

> أي أمر `tinker` يُنشئ ملفات (مثل PDF تجريبي) شغّله كـ `runuser -u sarfesak -- php artisan tinker` حتى لا تُنشأ ملفات يملكها root.

## أوامر لمرة واحدة (نُفّذت 2026-10-17)

```bash
php artisan nabdh:finance-backfill --dry-run   # ثم بدون --dry-run — فواتير الجلسات القديمة (آمن للتكرار)
php artisan db:seed --class=AssessmentTemplateSeeder --force   # مكتبة قوالب التقييم (لا يعمل إن وُجدت تصنيفات)
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

- **التاريخ:** 2026-10-17 — `master` @ `ea9a166` (آخر تغيير في الباك إند)
- **Migrations:** `create_finance_tables` · `create_assessment_reports_tables` · `add_letterhead_and_report_fields` · `allow_cv_in_therapist_documents` → DONE
- **Composer:** أُضيف `mpdf/mpdf` (تقارير PDF)
- **.env:** `APP_ENV=production` / `APP_DEBUG=false` (2026-10-13، نسخة `storage/app/env-backup-20261013`)
- **محمي ولم يُمس:** `.env` / `vendor/` (عدا composer) / ملفات `storage/` الموجودة

ما دخل منذ 2026-08-17: المكالمات (Agora + رنين)، إصلاح توكن Agora، واتساب +970/+972، النظام المالي، تقارير التقييم وقوالبها في لوحة التحكم، الترويسة ثنائية اللغة، الوثائق الخاصة وإصلاح السيرة الذاتية، إصلاح شاشة المصاريف. التفاصيل في [CHANGELOG.md](./CHANGELOG.md).

## نشر سابق

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
