import 'dart:convert';

import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/screen/login_screen/widget/forgot_password_sheet.dart';
import 'package:doctor_flutter/screen/dashboard_screen/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/doctor_profile_screen_one/doctor_profile_screen_one.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/doctor_profile_screen_three/doctor_profile_screen_three.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/doctor_profile_screen_two/doctor_profile_screen_two.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/select_category_screen/select_category_screen.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/starting_profile_screen/starting_profile_screen.dart';
import 'package:doctor_flutter/screen/registration_screen/registration_screen.dart';
import 'package:doctor_flutter/screen/registration_successful_screen.dart/registration_successful_screen.dart';
import 'package:doctor_flutter/service/session_manager.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/const_res.dart';
import 'package:doctor_flutter/utils/urls.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class LoginScreenController extends GetxController {
  TextEditingController phoneController    = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController forgotController   = TextEditingController();

  bool obscurePassword = true;
  String selectedCountryCode = '+970';

  void onCountryCodeChanged(String code) {
    selectedCountryCode = code;
    update();
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    update();
  }

  void onLoginClick() async {
    var localNumber = phoneController.text.trim();
    final password  = passwordController.text.trim();

    if (localNumber.isEmpty) return viewSnackBar('الرجاء إدخال رقم الهاتف');
    if (password.isEmpty)    return viewSnackBar('الرجاء إدخال كلمة المرور');

    // Remove leading zero if entered (e.g. 0594... → 594...)
    if (localNumber.startsWith('0')) localNumber = localNumber.substring(1);
    final phone = '$selectedCountryCode$localNumber';

    CustomUi.loader();
    try {
      final response = await http.post(
        Uri.parse(Urls.loginWithPhoneDoctor),
        headers: {'apikey': ConstRes.apiKey},
        body: {
          'phone':       phone,
          'password':    password,
          'deviceToken': 'flutter_${phone.replaceAll('+', '').replaceAll(' ', '')}',
          'deviceType':  '1',
        },
      );
      Get.back();

      final json = jsonDecode(response.body);
      if (json['status'] == true) {
        final reg = Registration.fromJson({
          'status':  json['status'],
          'message': json['message'],
          'data':    json['data'],
        });
        SessionManager.instance.setLogin(true);
        SessionManager.instance.setDoctor(reg.data);
        if (reg.data?.status == 0) {
          navigatePage(reg.data!);
        } else {
          Get.offAll(() => const DashboardScreen());
        }
      } else {
        viewSnackBar(json['message']?.toString() ?? 'فشل تسجيل الدخول');
      }
    } catch (e) {
      Get.back();
      viewSnackBar('خطأ في الاتصال بالخادم');
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

  void onForgotPasswordTap(BuildContext context) {
    forgotController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ForgotPasswordSheet(
          forgotController: forgotController,
          onPressed: onSendForgotPassword,
        ),
      ),
    );
  }

  void onSendForgotPassword() {
    Get.back();
    viewSnackBar('تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني');
  }

  void onRegisterTap() => Get.to(() => const RegistrationScreen());

  void viewSnackBar(String? title) {
    CustomUi.snackBar(
      message: title,
      textColor: ColorRes.havelockBlue,
      bgColor: ColorRes.white,
    );
  }
}
