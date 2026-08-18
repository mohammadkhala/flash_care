# توثيق مشروع نبض (NABD / Flash Care)

آخر تحديث: **2026-08-17** — السيرفر والكود المحلي على `master` @ `cf00c30`.

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
| [ENV_AND_NOTIFICATIONS.md](./ENV_AND_NOTIFICATIONS.md) | `.env` و Firebase و FCM |

## الحالة الحالية

| البند | الحالة |
|--------|--------|
| كود محلي | `master` @ `cf00c30` ✅ |
| سيرفر الإنتاج | نُشر 2026-08-17 ✅ |
| Firebase | `nabd-3e72e` ✅ |
| Migration الأخيرة | `add_media_name_to_program_exercises` DONE ✅ |
| APK على سطح المكتب | قديم (2026-06-09) — يحتاج إعادة بناء |

## تسجيل دخول الأدمن

- الرابط: `/admin/login`
- الهاتف: بدون مفتاح الدولة (مثال: `599000000`)
- بعد إعادة تعيين كلمة المرور عبر tinker على السيرفر إن لزم

## ملاحظات تشغيل مهمة

1. على السيرفر: `fetch` + `checkout nabdh_backend` + `rsync` ثم `migrate` + `cache`. لا تعتمد على `git pull` وحده.
2. `FIREBASE_PROJECT_ID` يجب أن يكون `nabd-3e72e` (بدون حرف **h**). القيمة `nabdh-3e72e` تسبب 403.
3. ميزات أغسطس (خريطة، مستندات، إشعارات صوتية، أكواد دول) تحتاج APK جديد على الجوال.
