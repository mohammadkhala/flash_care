import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/custom/countries.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/screen/complete_registration_screen/widget/country_sheet.dart';
import 'package:patient_flutter/screen/dashboard_screen/dashboard_screen.dart';
import 'package:patient_flutter/screen/login_screen/login_screen.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/services/session_manager.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/extention.dart';
import 'package:patient_flutter/utils/update_res.dart';

class CompleteRegistrationScreenController extends GetxController {
  List<String> genders = [S.current.male, S.current.female];
  String selectGender = S.current.male;
  TextEditingController countryController = TextEditingController();
  TextEditingController dateController =
      TextEditingController(text: DateTime.now().formatDateTime(ddMMMYyyy));
  DateTime selectedDate = DateTime.now();
  UserData? userData;
  List<Country> countries = [];
  List<Country> filterCountry = [];
  Country? selectCountry;
  Country? phoneCountry = Country(
    phoneCode: phoneCode,
    countryCode: countryCode,
    countryName: countryName,
  );
  TextEditingController phoneController = TextEditingController();

  int screenType;

  CompleteRegistrationScreenController(this.screenType);

  @override
  void onInit() {
    prefData();
    super.onInit();
  }

  void onGenderChange(String? value) {
    selectGender = value!;
    update();
  }

  void selectDate(BuildContext context) async {
    DateTime? newSelectedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.utc(DateTime.now().year, DateTime.now().month,
          DateTime.utc(DateTime.now().year, DateTime.now().month + 1, 0).day),
      builder: (context, child) {
        return Container(child: child);
      },
    );

    if (newSelectedDate != null) {
      selectedDate = newSelectedDate;
      dateController
        ..text = selectedDate.formatDateTime(ddMMMYyyy)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: dateController.text.length,
            affinity: TextAffinity.upstream));
    }
    update([kChangeDate]);
  }

  void prefData() async {
    userData = SessionManager.instance.getUser();
    countries = SessionManager.instance.getCountries()?.country ?? [];
    selectCountry = countries.first;
    filterCountry = SessionManager.instance.getCountries()?.country ?? [];
    if (userData?.phoneNumber != null &&
        (userData?.phoneNumber?.isNotEmpty ?? false)) {
      final parts = userData!.phoneNumber!.split(' ');
      phoneController = TextEditingController(text: parts[0]);
      if (parts.length > 1) {
        phoneCountry = countries.firstWhereOrNull(
            (element) => element.countryCode == parts[1]);
      }
    } else {
      final locale = ui.PlatformDispatcher.instance.locale;
      String? country = locale.countryCode;
      phoneCountry = countries
          .firstWhereOrNull((element) => element.countryCode == country);
      selectCountry = phoneCountry;
    }
    update();
  }

  void onSubmitBtnClick() async {
    if (phoneController.text.isEmpty) {
      CustomUi.snackBar(
        message: S.current.pleaseEnterMobileNumber,
      );
      return;
    }
    if (selectCountry == null) {
      CustomUi.snackBar(
        message: S.current.pleaseSelectYourCountry,
      );
      return;
    }
    CustomUi.loader();
    ApiService.instance
        .updateUserDetails(
      phoneNumber: phoneController.text.trim().isEmpty
          ? null
          : phoneController.text.trim(),
      countryCode: selectCountry?.phoneCode,
      gender: selectGender == S.current.male ? 1 : 0,
      dob: DateFormat(yyyyMMDd, 'en').format(selectedDate),
    )
        .then(
      (value) {
        if (value.status == true) {
          Get.back();
          CustomUi.snackBar(
              message:
                  S.current.registrationSuccessfullyDonePleaseLoginToContinue);
          if (screenType == 0) {
            Get.offAll(() => const LoginScreen());
          } else {
            Get.offAll(() => const DashboardScreen());
          }
        } else {
          Get.back();
          CustomUi.snackBar(
            message: value.message ?? '',
          );
        }
      },
    );
  }

  @override
  void onClose() {
    dateController.dispose();
    super.onClose();
  }

  void countryBottomSheet() {
    Get.bottomSheet(
      GetBuilder<CompleteRegistrationScreenController>(builder: (context) {
        return CountrySheet(
            country: filterCountry,
            onCountryChange: onCountryChange,
            onCountryTap: onCountryTap,
            controller: countryController);
      }),
      isScrollControlled: true,
    ).then((value) {
      countryController.clear();
      filterCountry = countries;
    });
  }

  void onCountryTap(Country value) {
    selectCountry = value;
    update();
    Get.back();
  }

  void onCountryChange(String value) {
    filterCountry = countries.where((element) {
      return (element.countryName ?? '')
          .isCaseInsensitiveContains(countryController.text);
    }).toList();
    update();
  }

  onPhoneCountrySelected(Country? p1) {
    phoneCountry = p1;
    update();
  }
}
