# بناء تطبيقات Android (APK)

## التطبيقات

| المجلد | التطبيق | ملف APK على سطح المكتب |
|--------|---------|------------------------|
| `nabdh_patient` | المريض | `NABD-Patient-v1.0.0.apk` |
| `nabdh_therapist` | الطبيب/الأخصائي | `NABD-Therapist-v1.0.0.apk` |

## قبل البناء — ضبط API الإنتاج

في كل تطبيق، الملف:

```
lib/core/constants/app_constants.dart
```

```dart
static const String baseUrl = 'https://doctor.baitpait.space/api'; // Production
```

## أوامر البناء

### المريض

```bash
cd nabdh_patient
flutter pub get
flutter build apk --release --split-per-abi
```

### الطبيب

```bash
cd nabdh_therapist
flutter pub get
flutter build apk --release --split-per-abi
```

## نسخ APK إلى سطح المكتب (arm64 — معظم الجوالات)

```bash
cp nabdh_patient/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk \
   ~/Desktop/NABD-Patient-v1.0.0.apk

cp nabdh_therapist/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk \
   ~/Desktop/NABD-Therapist-v1.0.0.apk
```

## أحجام تقريبية

| ABI | الحجم التقريبي |
|-----|----------------|
| arm64-v8a | ~38–41 MB |
| armeabi-v7a | ~33–34 MB |
| x86_64 | ~43 MB |

## التثبيت على الجوال

1. انقل ملف APK للجوال
2. فعّل «تثبيت من مصادر غير معروفة» إن لزم
3. ثبّت التطبيق المناسب (مريض ≠ طبيب)
4. **سجّل خروج ثم دخول** بعد التثبيت لتحديث توكن الإشعارات

## لماذا المحاكي كان يفشل

ليست مشكلة في كود التطبيق. الأسباب:

1. المحاكي ما زال يقلع عندما يبدأ `flutter run`
2. الأمر `flutter run -d android` غير صالح — Flutter يحتاج `emulator-5554`
3. محاكي API 36 أحياناً غير مستقر

تأكد أن `adb devices` يظهر `emulator-5554    device` قبل التشغيل.

## تشغيل على المحاكي (تطوير)

```bash
bash nabdh_therapist/scripts/run_emulator.sh
```

أو يدوياً:

```bash
adb devices   # يجب أن يظهر emulator-5554 device
cd nabdh_therapist
flutter run -d emulator-5554
```

> لا تستخدم `-d android` — استخدم معرّف الجهاز الفعلي.

## Firebase في التطبيق

ملف `android/app/google-services.json` يجب أن يحتوي:

```json
"project_id": "nabd-3e72e"
```

يجب أن يطابق `FIREBASE_PROJECT_ID` على السيرفر.

## آخر بناء موثّق

- **التاريخ:** 2026-06-09
- **الفرع وقت البناء:** `master` @ `9d43381`
- **ملاحظة:** السيرفر محدّث إلى `cf00c30` (2026-08-17). أعد بناء APK قبل تجربة التعديلات الجديدة على الجوال.
