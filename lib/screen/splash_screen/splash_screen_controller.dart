import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/custom/countries.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/screen/complete_registration_screen/complete_registration_screen.dart';
import 'package:patient_flutter/screen/dashboard_screen/dashboard_screen.dart';
import 'package:patient_flutter/screen/login_screen/login_screen.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/services/session_manager.dart';
import 'package:patient_flutter/utils/asset_res.dart';
import 'package:patient_flutter/utils/update_res.dart';

class SplashScreenController extends GetxController {
  UserData? userData;
  Countries? country;
  bool isLoading = false;
  bool isLogin = false;

  @override
  void onInit() {
    super.onInit();
    initializeData();
  }

  Future<void> initializeData() async {
    await _loadCountryData();
    _loadUserPreferences();
    navigateRoot();
  }

  Future<void> _loadCountryData() async {
    final response = await rootBundle.loadString(AssetRes.countryJson);
    country = Countries.fromJson(jsonDecode(response));
    final encodedData = jsonEncode(country?.toJson());
    SessionManager.instance.setString(key: kCountries, value: encodedData);
  }

  void _loadUserPreferences() {
    isLogin = SessionManager.instance.isLogin();
    userData = SessionManager.instance.getUser();
  }

  Future<void> navigateRoot() async {
    _setLoadingState(true);

    final settingsResponse = await ApiService.instance.fetchGlobalSettings();
    print('-------- ${settingsResponse.status} -------');
    if (settingsResponse.status != true) {
      _handleError(S.current.somethingWentWrong);
      return;
    }

    dollar = settingsResponse.data?.currency ?? '\$';

    if (SessionManager.instance.getUserID() <= 0) {
      return Get.off(() => const LoginScreen());
    } else {
      final profileResponse = await ApiService.instance.fetchMyUserDetails();
      if (profileResponse.status != true) {
        _handleError(S.current.somethingWentWrong);
        return;
      }
      _processProfile(profileResponse.data);
    }
    _setLoadingState(false);
  }

  void _processProfile(UserData? profile) {
    if (profile?.phoneNumber == null || profile!.phoneNumber!.isEmpty) {
      Get.off(() => CompleteRegistrationScreen(screenType: isLogin ? 1 : 0));
    } else {
      Get.offAll(() => const DashboardScreen());
    }
  }

  void _setLoadingState(bool state) {
    isLoading = state;
    update();
  }

  void _handleError(String message) {
    isLoading = false;
    CustomUi.snackBar(message: message);
    update();
  }
}
