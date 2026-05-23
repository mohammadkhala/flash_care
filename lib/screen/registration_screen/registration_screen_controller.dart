import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/screen/complete_registration_screen/complete_registration_screen.dart';
import 'package:patient_flutter/screen/dashboard_screen/dashboard_screen.dart';
import 'package:patient_flutter/services/session_manager.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/urls.dart';

class RegistrationScreenController extends GetxController {
  // Step 0 — phone
  TextEditingController phoneController = TextEditingController();

  // Step 1 — OTP
  TextEditingController otpController = TextEditingController();

  // Step 2 — details
  TextEditingController fullNameController    = TextEditingController();
  TextEditingController passwordController    = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

  // Country code
  String selectedCountryCode = '+970';
  void onCountryCodeChanged(String code) { selectedCountryCode = code; update(); }

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

    final fullPhone = '$selectedCountryCode${phoneController.text.trim()}';

    CustomUi.loader();
    try {
      final res = await http.post(
        Uri.parse(Urls.sendOtp),
        headers: {pApikeyName: ConstRes.apiKey},
        body: {'phone': fullPhone},
      );
      Get.back();
      final json = jsonDecode(res.body);
      if (json['status'] == true) {
        _phone = fullPhone;
        step = 1;
        update();
      } else {
        _snack(json['message']?.toString() ?? 'Failed to send OTP');
      }
    } catch (_) {
      Get.back();
      _snack('Network error. Please try again.');
    }
  }

  // ── Step 1: Verify OTP ──────────────────────────────────────────────────
  void onVerifyOtpClick() async {
    final otp = otpController.text.trim();
    if (otp.isEmpty || otp.length != 6) return _snack('Enter the 6-digit OTP');

    // We only verify the OTP code here locally by moving to step 2.
    // The actual DB record creation happens at step 2 with the password.
    // But we must confirm the OTP is valid first via a lightweight check.
    CustomUi.loader();
    try {
      // Re-use sendOtp route? No — call verifyOtpUser without a password just
      // to validate, then overwrite at step 2. Instead we simply trust the OTP
      // and pass it at step 2. Move to details screen now.
      Get.back();
      step = 2;
      update();
    } catch (_) {
      Get.back();
      _snack('Something went wrong.');
    }
  }

  // ── Step 2: Create Account ───────────────────────────────────────────────
  void onCreateAccountClick() async {
    fullNameError    = fullNameController.text.trim().isEmpty;
    passwordError    = passwordController.text.trim().isEmpty;
    confirmPassError = confirmPassController.text.trim().isEmpty;
    update();

    if (fullNameError || passwordError || confirmPassError) return;

    if (passwordController.text.trim() != confirmPassController.text.trim()) {
      return _snack('Passwords do not match');
    }
    if (passwordController.text.trim().length < 6) {
      return _snack('Password must be at least 6 characters');
    }

    CustomUi.loader();
    try {
      final res = await http.post(
        Uri.parse(Urls.verifyOtpUser),
        headers: {pApikeyName: ConstRes.apiKey},
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
        final reg = Registration.fromJson({
          'status':  json['status'],
          'message': json['message'],
          'data':    json['data'],
        });
        SessionManager.instance.setLogin(true);
        SessionManager.instance.setUser(reg.data);

        final data = reg.data;
        if ([data?.countryCode, data?.gender, data?.dob].any((e) => e == null)) {
          Get.offAll(() => const CompleteRegistrationScreen(screenType: 0));
        } else {
          Get.offAll(() => const DashboardScreen());
        }
      } else {
        _snack(json['message']?.toString() ?? 'Registration failed. OTP may have expired.');
      }
    } catch (_) {
      Get.back();
      _snack('Network error. Please try again.');
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
