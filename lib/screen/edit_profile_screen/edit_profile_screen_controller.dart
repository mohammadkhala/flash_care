import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/custom/countries.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/screen/complete_registration_screen/widget/country_sheet.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/services/session_manager.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/extention.dart';
import 'package:patient_flutter/utils/update_res.dart';

class EditProfileScreenController extends GetxController {
  List<String> genders = [S.current.male, S.current.female];
  String selectGender = S.current.male;

  UserData? userData;
  TextEditingController fullNameController = TextEditingController();
  TextEditingController searchCountryController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  TextEditingController dateController =
      TextEditingController(text: DateTime.now().formatDateTime(ddMMMYyyy));
  DateTime selectedDate = DateTime.now();
  String? netWorkImage;
  File? imageFile;
  List<Country> countries = [];
  List<Country> filterCountry = [];
  Country? selectCountry;
  Country? phoneCountry;

  @override
  void onInit() {
    prefData();
    super.onInit();
  }

  void prefData() async {
    userData = SessionManager.instance.getUser();
    countries = SessionManager.instance.getCountries()?.country ?? [];
    filterCountry = SessionManager.instance.getCountries()?.country ?? [];
    if (userData?.phoneNumber != null &&
        userData?.phoneNumber != 'null' &&
        (userData?.phoneNumber?.isNotEmpty ?? false)) {
      phoneNumberController =
          TextEditingController(text: userData?.phoneNumber?.split(' ')[0]);
      phoneCountry = countries.firstWhere((element) =>
          element.countryCode == userData?.phoneNumber?.split(' ')[1]);
    } else {}
    selectCountry = countries
        .firstWhere((element) => element.phoneCode == userData?.countryCode);
    if (userData?.dob != null || userData!.dob!.isNotEmpty) {
      dateController = TextEditingController(
          text: DateFormat(ddMMMYyyy).format(DateTime.parse(
              userData?.dob ?? DateTime.now().formatDateTime(ddMMMYyyy))));
      selectedDate = DateTime.parse(
          userData?.dob ?? DateTime.now().formatDateTime(ddMMMYyyy));
    }
    selectGender = userData?.gender == 1 ? S.current.male : S.current.female;

    fullNameController = TextEditingController(text: userData?.fullname ?? '');
    netWorkImage = userData?.profileImage;

    update();
  }

  void onImageTap() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
        maxHeight: maxHeight,
        maxWidth: maxWidth);
    if (image != null) {
      imageFile = File(image.path);
      update();
    }
  }

  void onContinueTap() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (selectCountry == null) {
      return CustomUi.snackBar(
        message: S.current.pleaseSelectYourCountry,
      );
    }

    CustomUi.loader();
    ApiService.instance
        .updateUserDetails(
      image: imageFile,
      name: fullNameController.text,
      phoneNumber: phoneNumberController.text.trim().isEmpty
          ? null
          : '${phoneNumberController.text.trim()} ${phoneCountry?.countryCode}',
      countryCode: selectCountry?.phoneCode,
      gender: selectGender == S.current.male ? 1 : 0,
      dob: DateFormat(yyyyMMDd, 'en').format(selectedDate),
    )
        .then((value) {
      Get.back();
      if (value.status == true) {
        Get.back();
        CustomUi.snackBar(message: value.message);
      } else {
        CustomUi.snackBar(message: value.message);
      }
    });
  }

  void countryBottomSheet() {
    Get.bottomSheet(
      GetBuilder<EditProfileScreenController>(builder: (context) {
        return CountrySheet(
            country: filterCountry,
            onCountryChange: onCountryChange,
            onCountryTap: onCountryTap,
            controller: searchCountryController);
      }),
      isScrollControlled: true,
    ).then((value) {
      searchCountryController.clear();
      filterCountry = countries;
    });
  }

  void onCountryTap(Country? value) {
    selectCountry = value;
    update();
    Get.back();
  }

  onSelectedCountry(Country? p1) {
    phoneCountry = p1!;
    update();
  }

  void onCountryChange(String value) {
    filterCountry = countries.where((element) {
      return (element.countryName ?? '')
          .isCaseInsensitiveContains(searchCountryController.text);
    }).toList();
    update();
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
    update();
  }
}
