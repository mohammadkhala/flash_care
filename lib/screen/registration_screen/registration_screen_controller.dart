import 'dart:convert';

import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/screen/dashboard_screen/dashboard_screen.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/doctor_profile_screen_one/doctor_profile_screen_one.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/doctor_profile_screen_three/doctor_profile_screen_three.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/doctor_profile_screen_two/doctor_profile_screen_two.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/select_category_screen/select_category_screen.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/starting_profile_screen/starting_profile_screen.dart';
import 'package:doctor_flutter/screen/registration_successful_screen.dart/registration_successful_screen.dart';
import 'package:doctor_flutter/service/session_manager.dart';
import 'package:doctor_flutter/utils/urls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

const String _apiKey = '123';

class RegistrationScreenController extends GetxController {
  // Step 0 — phone
  TextEditingController phoneController = TextEditingController();

  // Step 1 — OTP
  TextEditingController otpController = TextEditingController();

  // Step 2 — details
  TextEditingController fullNameController    = TextEditingController();
  TextEditingController passwordController    = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

  // Flags
  bool phoneError       = false;
  bool fullNameError    = false;
  bool passwordError    = false;
  bool confirmPassError = false;
  bool obscurePass      = true;
  bool obscureConfirm   = true;

  /// 0 = phone  |  1 = OTP  |  2 = name+password
  int step = 0;

  String _phone = '';

  // ── Step 0: Send OTP ────────────────────────────────────────────────────
  void onSendOtpClick() async {
    phoneError = phoneController.text.trim().isEmpty;
    update();
    if (phoneError) return;

    CustomUi.loader();
    try {
      final res = await http.post(
        Uri.parse(Urls.sendOtp),
        headers: {'apikey': _apiKey},
        body: {'phone': phoneController.text.trim()},
      );
      Get.back();
      final json = jsonDecode(res.body);
      if (json['status'] == true) {
        _phone = phoneController.text.trim();
        step = 1;
        update();
      } else {
        _snack(json['message']?.toString() ?? 'فشل إرسال رمز التحقق');
      }
    } catch (e) {
      Get.back();
      _snack('خطأ: $e');
    }
  }

  // ── Step 1: Verify OTP (move to details) ────────────────────────────────
  void onVerifyOtpClick() {
    final otp = otpController.text.trim();
    if (otp.isEmpty || otp.length != 6) return _snack('أدخل رمز التحقق المكوّن من 6 أرقام');
    step = 2;
    update();
  }

  // ── Step 2: Create Account ───────────────────────────────────────────────
  void onCreateAccountClick() async {
    fullNameError    = fullNameController.text.trim().isEmpty;
    passwordError    = passwordController.text.trim().isEmpty;
    confirmPassError = confirmPassController.text.trim().isEmpty;
    update();

    if (fullNameError || passwordError || confirmPassError) return;

    if (passwordController.text.trim() != confirmPassController.text.trim()) {
      return _snack('كلمتا المرور غير متطابقتين');
    }
    if (passwordController.text.trim().length < 6) {
      return _snack('يجب أن تكون كلمة المرور 6 أحرف على الأقل');
    }

    CustomUi.loader();
    try {
      final res = await http.post(
        Uri.parse(Urls.verifyOtpDoctor),
        headers: {'apikey': _apiKey},
        body: {
          'phone':       _phone,
          'otp':         otpController.text.trim(),
          'name':        fullNameController.text.trim(),
          'password':    passwordController.text.trim(),
          'deviceToken': '',
          'deviceType':  '1',
        },
      );
      Get.back();
      final json = jsonDecode(res.body);

      if (json['status'] == true) {
        final isNewDoctor = json['isNewDoctor'] == true;

        final reg = Registration.fromJson({
          'status':  json['status'],
          'message': json['message'],
          'data':    json['data'],
        });

        // حفظ الـ session للطبيب الجديد والقديم على حدٍّ سواء
        SessionManager.instance.setLogin(true);
        SessionManager.instance.setDoctor(reg.data);

        if (isNewDoctor) {
          // طبيب جديد — اذهب لإكمال الملف الشخصي (بدون هاتف)
          Get.offAll(() => StartingProfileScreen(doctorData: reg.data));
        } else {
          if (reg.data?.status == 0) {
            navigatePage(reg.data!);
          } else {
            Get.offAll(() => const DashboardScreen());
          }
        }
      } else {
        _snack(json['message']?.toString() ?? 'فشل التسجيل. قد يكون رمز التحقق قد انتهت صلاحيته.');
      }
    } catch (e) {
      Get.back();
      _snack('خطأ: $e');
    }
  }

  void navigatePage(DoctorData data) {
    if (data.mobileNumber == null || data.gender == null) {
      Get.offAll(() => StartingProfileScreen(doctorData: data));
    } else if (data.categoryId == null) {
      Get.offAll(() => const SelectCategoryScreen(screenType: 0));
    } else if ([data.image, data.designation, data.degrees,
                data.experienceYear, data.consultationFee].any((e) => e == null)) {
      Get.offAll(() => const DoctorProfileScreenOne());
    } else if (data.aboutYouself == null || data.educationalJourney == null) {
      Get.offAll(() => const DoctorProfileScreenTwo());
    } else if (data.onlineConsultation == 0 && data.clinicConsultation == 0) {
      Get.offAll(() => const DoctorProfileScreenThree());
    } else {
      Get.offAll(() => const RegistrationSuccessfulScreen());
    }
  }

  void toggleObscurePass() {
    obscurePass = !obscurePass;
    update();
  }

  void toggleObscureConfirm() {
    obscureConfirm = !obscureConfirm;
    update();
  }

  void onResendOtp() {
    otpController.clear();
    step = 0;
    update();
    onSendOtpClick();
  }

  void goBack() {
    if (step > 0) {
      step--;
      update();
    } else {
      Get.back();
    }
  }

  void _snack(String msg) => CustomUi.snackBar(message: msg);
}
