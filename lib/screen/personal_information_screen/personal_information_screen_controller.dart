import 'dart:convert';
import 'dart:ui' as ui;

import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/countries/countries.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/model/doctor_category/doctor_category.dart';
import 'package:doctor_flutter/service/api_service.dart';
import 'package:doctor_flutter/service/session_manager.dart';
import 'package:doctor_flutter/utils/asset_res.dart';
import 'package:doctor_flutter/utils/const_res.dart';
import 'package:doctor_flutter/utils/update_res.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
// import 'package:intl_phone_number_input_v2/intl_phone_number_input.dart';

class PersonalInformationScreenController extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController designationController = TextEditingController();
  TextEditingController degreeController = TextEditingController();
  TextEditingController languageController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  TextEditingController feesController = TextEditingController();

  // PhoneNumber phoneNumber = PhoneNumber();
  List<Country> countries = [];
  Country? selectCountry;
  DoctorCategoryData? selectCategory;
  DoctorData? doctorData;
  String? netWorkProfileImage;
  XFile? profileImage;
  List<DoctorCategoryData>? categoryData;
  bool isLoading = false;

  FocusNode nameFocusNode = FocusNode();
  FocusNode designationFocusNode = FocusNode();
  FocusNode degreeFocusNode = FocusNode();
  FocusNode languageFocusNode = FocusNode();
  FocusNode yearFocusNode = FocusNode();
  FocusNode feesFocusNode = FocusNode();

  TextEditingController phoneNumberEditController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchCategoryApiCall();
  }

  void prefData() async {
    if (doctorData != null) {
      netWorkProfileImage = doctorData?.image;
      nameController =
          TextEditingController(text: doctorData?.name ?? S.current.unKnown);
      designationController = TextEditingController(
          text: doctorData?.designation ?? S.current.addYourDesignation);
      degreeController = TextEditingController(
          text: doctorData?.degrees ?? S.current.addYourDegreesEtc);
      languageController =
          TextEditingController(text: doctorData?.languagesSpoken ?? '');
      yearController = TextEditingController(
          text: doctorData?.experienceYear.toString() ?? '');
      feesController = TextEditingController(
          text: NumberFormat(numberFormat).format(doctorData?.consultationFee));

      if (doctorData?.mobileNumber != null &&
          doctorData?.mobileNumber != 'null' &&
          (doctorData?.mobileNumber?.isNotEmpty ?? false)) {
        phoneNumberEditController = TextEditingController(
            text: doctorData?.mobileNumber?.split(' ')[0]);
      } else {
        final locale = ui.PlatformDispatcher.instance.locale;
        String? countryCode = locale.countryCode;

        selectCountry = countries
            .firstWhereOrNull((element) => element.countryCode == countryCode);
      }
      selectCategory = categoryData?.firstWhere((element) {
        return element.id == doctorData?.categoryId;
      });
      if ((doctorData?.countryCode ?? '').isNotEmpty) {
        selectCountry = countries.firstWhere((element) {
          return element.phoneCode == doctorData?.countryCode;
        });
      } else {
        selectCountry = countries.first;
      }
      update();
    }
  }

  void unFocusFiled() {
    nameFocusNode.unfocus();
    designationFocusNode.unfocus();
    degreeFocusNode.unfocus();
    languageFocusNode.unfocus();
    yearFocusNode.unfocus();
    feesFocusNode.unfocus();
  }

  void onCategoryChange(DoctorCategoryData? value) {
    selectCategory = value!;
    update();
  }

  Future<void> getCountryData() async {
    String response = await rootBundle.loadString(AssetRes.countryJson);
    countries = Countries.fromJson(json.decode(response)).country ?? [];
    prefData();
    update();
  }

  void fetchCategoryApiCall() async {
    doctorData = SessionManager.instance.getDoctor();
    categoryData = SessionManager.instance.getCategories();
    update();
    getCountryData();
  }

  void onDesignationChange(String value) {
    update();
  }

  void onDegreeChange(String value) {
    update();
  }

  void updateDoctor() {
    if (profileImage == null && netWorkProfileImage == null) {
      CustomUi.snackBar(
        message: S.current.pleaseSelectProfileImage,
      );
      return;
    }
    if (nameController.text.isEmpty) {
      CustomUi.snackBar(
        message: S.current.pleaseEnterName,
      );
      return;
    }
    if (designationController.text.isEmpty) {
      CustomUi.snackBar(
        message: S.current.pleaseEnterDesignation,
      );
      return;
    }
    if (degreeController.text.isEmpty) {
      CustomUi.snackBar(
        message: S.current.pleaseEnterDegree,
      );
      return;
    }
    if (languageController.text.isEmpty) {
      CustomUi.snackBar(
        message: S.current.pleaseEnterLanguages,
      );
      return;
    }
    if (yearController.text.isEmpty) {
      CustomUi.snackBar(
        message: S.current.pleaseEnterYearOfExperience,
      );
      return;
    }
    if (feesController.text.isEmpty) {
      CustomUi.snackBar(message: S.current.pleaseEnterConsultationFee);
      return;
    }

    unFocusFiled();
    CustomUi.loader();
    ApiService.instance
        .updateDoctorDetails(
      image: profileImage,
      mobileNumber: phoneNumberEditController.text.trim().isEmpty
          ? null
          : phoneNumberEditController.text.trim(),
      countryCode: selectCountry?.phoneCode,
      name: nameController.text,
      designation: designationController.text,
      degrees: degreeController.text,
      languagesSpoken: languageController.text,
      experienceYear: yearController.text,
      consultationFee: feesController.text.replaceAll(',', ''),
    )
        .then((value) {
      Get.back();
      CustomUi.snackBarMaterial(value.message);
      if (value.status == true) {
        Get.back();
      }
    });
  }

  void onNameChange(String value) {
    update();
  }

  void onImagePick() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight);
    if (image != null) {
      profileImage = image;
    }
    update();
  }

  // void onInputChanged(PhoneNumber value) {
  //   phoneNumber = value;
  //   update();
  // }

  onSelectedCountry(Country? p1) {
    selectCountry = p1;
    update();
  }
}
