import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/screen/dashboard_screen/dashboard_screen.dart';
import 'package:patient_flutter/screen/login_screen/widget/forgot_password_sheet.dart';
import 'package:patient_flutter/screen/registration_screen/registration_screen.dart';
import 'package:patient_flutter/services/session_manager.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/urls.dart';

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
        Uri.parse(Urls.loginWithPhone),
        headers: {pApikeyName: ConstRes.apiKey},
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
        SessionManager.instance.setUser(reg.data);
        Get.offAll(() => const DashboardScreen());
      } else {
        viewSnackBar(json['message']?.toString() ?? 'فشل تسجيل الدخول');
      }
    } catch (e) {
      Get.back();
      viewSnackBar('خطأ في الاتصال بالخادم');
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
