import 'dart:developer';

import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/screen/dashboard_screen/dashboard_screen.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/doctor_profile_screen_one/doctor_profile_screen_one.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/doctor_profile_screen_three/doctor_profile_screen_three.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/doctor_profile_screen_two/doctor_profile_screen_two.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/select_category_screen/select_category_screen.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/starting_profile_screen/starting_profile_screen.dart';
import 'package:doctor_flutter/screen/login_screen/login_screen.dart';
import 'package:doctor_flutter/screen/registration_successful_screen.dart/registration_successful_screen.dart';
import 'package:doctor_flutter/service/api_service.dart';
import 'package:doctor_flutter/service/session_manager.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreenController extends GetxController {
  bool _isLogin = false;

  @override
  void onInit() async {
    super.onInit();
    await _initializePreferences();
    await _navigateBasedOnUser();
  }

  Future<void> _initializePreferences() async {
    _isLogin = SessionManager.instance.isLogin();
  }

  Future<void> _navigateBasedOnUser() async {
    if (SessionManager.instance.getDoctorId() <= 0) {
      _navigateTo(const LoginScreen());
      return;
    }

    Registration response = await ApiService.instance.fetchMyDoctorProfile();

    if (response.status == false) {
      _navigateTo(const LoginScreen());
      return;
    }

    final doctorData = response.data;
    if (doctorData == null) {
      _navigateTo(const LoginScreen());
      return;
    }

    _handleDoctorNavigation(doctorData);
  }

  void _handleDoctorNavigation(DoctorData data) {
    if (!_isLogin) {
      _navigateToNextProfileStep(data);
      return;
    }

    log('message ${data.status}');
    switch (data.status) {
      case 0:
        _navigateToNextProfileStep(data);
        break;
      case 1:
        Get.off(const DashboardScreen());
        break;
      case 2:
        viewSnackBar(message: S.current.doctorBanned);
        break;
      default:
        _navigateTo(const LoginScreen());
    }
  }

  void _navigateToNextProfileStep(DoctorData data) {
    if (data.mobileNumber == null || data.gender == null) {
      _navigateTo(StartingProfileScreen(doctorData: data));
    } else if (data.categoryId == null) {
      _navigateTo(const SelectCategoryScreen(screenType: 0));
    } else if ([
      data.image,
      data.designation,
      data.degrees,
      data.experienceYear,
      data.consultationFee
    ].any((element) => element == null)) {
      _navigateTo(const DoctorProfileScreenOne());
    } else if (data.aboutYouself == null || data.educationalJourney == null) {
      _navigateTo(const DoctorProfileScreenTwo());
    } else if (data.onlineConsultation == 0 && data.clinicConsultation == 0) {
      _navigateTo(const DoctorProfileScreenThree());
    } else if (_isLogin && data.status == 1) {
      _navigateTo(const DashboardScreen());
    } else if (data.status == 2) {
      viewSnackBar(message: S.current.doctorBanned);
    } else {
      _navigateTo(const RegistrationSuccessfulScreen());
    }
  }

  void viewSnackBar({String? message}) {
    CustomUi.snackBar(
        message: message,
        textColor: ColorRes.havelockBlue,
        bgColor: ColorRes.white);
  }

  void _navigateTo(Widget screen) {
    Get.offAll(() => screen);
  }
}
