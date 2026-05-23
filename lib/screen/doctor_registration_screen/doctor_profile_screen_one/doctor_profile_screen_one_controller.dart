import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/doctor_profile_screen_three/doctor_profile_screen_three.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/doctor_profile_screen_two/doctor_profile_screen_two.dart';
import 'package:doctor_flutter/screen/registration_successful_screen.dart/registration_successful_screen.dart';
import 'package:doctor_flutter/service/api_service.dart';
import 'package:doctor_flutter/service/session_manager.dart';
import 'package:doctor_flutter/utils/const_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class DoctorProfileScreenOneController extends GetxController {
  TextEditingController designationController = TextEditingController();
  TextEditingController degreeController = TextEditingController();
  TextEditingController languageController = TextEditingController();
  TextEditingController experienceController = TextEditingController();
  TextEditingController feesController = TextEditingController();
  FocusNode designationFocusNode = FocusNode();
  FocusNode degreeFocusNode = FocusNode();
  FocusNode languageFocusNode = FocusNode();
  FocusNode experienceFocusNode = FocusNode();
  FocusNode feesFocusNode = FocusNode();

  DoctorData? userData;
  String? netWorkProfileImage;
  XFile? profileImage;

  @override
  void onInit() {
    prefData();
    super.onInit();
  }

  void onDesignationChange(String value) {
    update();
  }

  void onDegreeChange(String value) {
    update();
  }

  void unFocusFiled() {
    designationFocusNode.unfocus();
    degreeFocusNode.unfocus();
    languageFocusNode.unfocus();
    experienceFocusNode.unfocus();
    feesFocusNode.unfocus();
  }

  void prefData() async {
    userData = SessionManager.instance.getDoctor();
    designationController = TextEditingController(text: userData?.designation ?? '');
    degreeController = TextEditingController(text: userData?.degrees ?? '');
    languageController = TextEditingController(text: userData?.languagesSpoken ?? '');
    experienceController = TextEditingController(text: '${userData?.experienceYear ?? ''}');
    feesController = TextEditingController(text: '${userData?.consultationFee ?? ''}');
    final img = userData?.image;
    netWorkProfileImage = (img == null || img == 'null' || img.trim().isEmpty) ? null : img;
    update();
  }

  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: imageQuality, maxHeight: maxHeight, maxWidth: maxWidth);
    if (image != null) {
      profileImage = image;
    }
    update();
  }

  void updateDoctor() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (profileImage == null && netWorkProfileImage == null) {
      CustomUi.snackBar(message: S.current.pleaseSelectProfileImage);
      return;
    }
    if (designationController.text.isEmpty) {
      CustomUi.snackBar(message: S.current.pleaseEnterDesignation);
      return;
    }
    if (degreeController.text.isEmpty) {
      CustomUi.snackBar(message: S.current.pleaseEnterDegree);
      return;
    }
    if (languageController.text.isEmpty) {
      CustomUi.snackBar(message: S.current.pleaseEnterLanguages);
      return;
    }
    if (experienceController.text.isEmpty) {
      CustomUi.snackBar(message: S.current.pleaseEnterYearOfExperience);
      return;
    }
    if (feesController.text.isEmpty) {
      CustomUi.snackBar(message: S.current.pleaseEnterConsultationFee);
      return;
    }
    CustomUi.loader();
    ApiService.instance
        .updateDoctorDetails(
      image: profileImage,
      designation: designationController.text,
      degrees: degreeController.text,
      languagesSpoken: languageController.text,
      experienceYear: experienceController.text,
      consultationFee: feesController.text.replaceAll(',', ''),
    )
        .then((value) {
      Get.back();
      if (value.status == true) {
        navigateRoot();
      } else {
        CustomUi.snackBar(message: value.message ?? 'فشلت العملية.');
      }
    }).catchError((e) {
      Get.back();
      CustomUi.snackBar(message: 'خطأ: $e');
    });
  }

  void navigateRoot() {
    if (userData?.aboutYouself == null || userData?.educationalJourney == null) {
      Get.off(() => const DoctorProfileScreenTwo());
    } else if (userData?.onlineConsultation == 0 && userData?.clinicConsultation == 0) {
      Get.off(() => const DoctorProfileScreenThree());
    } else {
      Get.offAll(() => const RegistrationSuccessfulScreen());
    }
  }
}
