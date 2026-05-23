import 'dart:convert';
import 'dart:ui' as ui;

import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/countries/countries.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/doctor_profile_screen_one/doctor_profile_screen_one.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/doctor_profile_screen_three/doctor_profile_screen_three.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/doctor_profile_screen_two/doctor_profile_screen_two.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/select_category_screen/select_category_screen.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/starting_profile_screen/widget/country_sheet.dart';
import 'package:doctor_flutter/screen/registration_successful_screen.dart/registration_successful_screen.dart';
import 'package:doctor_flutter/service/api_service.dart';
import 'package:doctor_flutter/service/session_manager.dart';
import 'package:doctor_flutter/utils/asset_res.dart';
import 'package:doctor_flutter/utils/const_res.dart';
import 'package:doctor_flutter/utils/update_res.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
// import 'package:intl_phone_number_input_v2/intl_phone_number_input.dart';

class StartingProfileScreenController extends GetxController {
  List<Country> countries = [];
  List<Country> filterCountries = [];
  List<String> genders = [S.current.male, S.current.feMale];
  Country? selectCountry;
  String selectGender = S.current.male;
  DoctorData? doctorData;

  StartingProfileScreenController(this.doctorData);

  // PhoneNumber phoneNumber = PhoneNumber();
  TextEditingController countryController = TextEditingController();

  TextEditingController phoneController = TextEditingController();

  @override
  void onInit() {
    readJson();
    super.onInit();
  }

  void onGenderChange(String? value) {
    selectGender = value!;
    update([kSelectGender]);
  }

  Future<void> readJson() async {
    String response = await rootBundle.loadString(AssetRes.countryJson);
    countries = Countries.fromJson(json.decode(response)).country ?? [];
    filterCountries = Countries.fromJson(json.decode(response)).country ?? [];
    selectCountry =
        countries.firstWhere((element) => element.countryCode == countryCode);
    prefData();
    update([kSelectCountries]);
  }

  void prefData() async {
    doctorData = SessionManager.instance.getDoctor();

    if (doctorData?.mobileNumber != null &&
        doctorData!.mobileNumber!.isNotEmpty) {
      phoneController =
          TextEditingController(text: doctorData?.mobileNumber?.split(' ')[0]);
      selectCountry = countries.firstWhere(
          (element) => element.phoneCode == doctorData?.countryCode);
    } else {
      final locale = ui.PlatformDispatcher.instance.locale;
      String? countryCode = locale.countryCode;
      selectCountry = countries
          .firstWhereOrNull((element) => element.countryCode == countryCode);
    }
    selectGender = doctorData?.gender == 1 ? S.current.male : S.current.feMale;
    update();
  }

  void navigateRoot(DoctorData data) {
    if (data.categoryId == null) {
      Get.off(() => const SelectCategoryScreen(screenType: 0));
    } else if (data.image == null ||
        data.designation == null ||
        data.degrees == null ||
        data.experienceYear == null ||
        data.consultationFee == null) {
      Get.off(() => const DoctorProfileScreenOne());
    } else if (data.aboutYouself == null || data.educationalJourney == null) {
      Get.off(() => const DoctorProfileScreenTwo());
    } else if (data.onlineConsultation == 0 && data.clinicConsultation == 0) {
      Get.off(() => const DoctorProfileScreenThree());
    } else {
      Get.offAll(() => const RegistrationSuccessfulScreen());
    }
  }

  void countryBottomSheet(StartingProfileScreenController controller) {
    FocusManager.instance.primaryFocus?.unfocus();
    Get.bottomSheet(
      GetBuilder(
        init: controller,
        builder: (controller) => CountrySheet(
            country: filterCountries,
            onCountryChange: onCountryChange,
            onCountryTap: onCountryTap,
            controller: countryController,
            screenController: controller),
      ),
      isScrollControlled: true,
    ).then((value) {
      countryController.clear();
      filterCountries = countries;
    });
  }

  void onCountryTap(Country value) {
    selectCountry = value;
    update();
    Get.back();
  }

  void onCountryChange(String value) {
    filterCountries = countries.where((element) {
      return (element.countryName ?? '')
          .isCaseInsensitiveContains(countryController.text);
    }).toList();
    update();
  }

  // void onInputChanged(PhoneNumber value) {
  //   phoneNumber = value;
  //   selectCountry = countries.firstWhere((element) => element.countryCode == value.isoCode);
  //   update();
  // }

  onSelectedCountry(Country? p1) {
    selectCountry = p1;
    update();
  }

  void updateDoctor() {
    FocusManager.instance.primaryFocus?.unfocus();

    CustomUi.loader();
    ApiService.instance
        .updateDoctorDetails(
      countryCode: selectCountry?.phoneCode,
      gender: selectGender == S.current.male ? 1 : 0,
      mobileNumber: phoneController.text.trim().isEmpty
          ? null
          : phoneController.text.trim(),
    )
        .then((value) {
      if (value.status == true) {
        Get.back();
        navigateRoot(value.data!);
      } else {
        Get.back();
        CustomUi.snackBar(message: 'فشلت العملية. الرجاء المحاولة مجدداً.');
      }
    }).catchError((e) {
      Get.back();
      CustomUi.snackBar(message: 'خطأ في الشبكة. الرجاء المحاولة مجدداً.');
    });
  }

  @override
  void onClose() {
    countryController.dispose();
    super.onClose();
  }
}
