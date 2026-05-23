import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/appointment/fetch_appointment.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/screen/manage_patient_screen/widget/add_patient_sheet.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/services/session_manager.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/update_res.dart';

class ManagePatientScreenController extends GetxController {
  List<Patient> patients = [];
  bool isLoading = false;
  TextEditingController fullNameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController relationController = TextEditingController();
  bool isFullName = false;
  bool isAge = false;
  bool isRelation = false;
  final genders = [S.current.male, S.current.female];
  String selectGender = S.current.male;
  String? networkImage;
  File? imageFile;

  UserData? userData;

  @override
  void onInit() {
    prefData();
    super.onInit();
  }

  void fetchPatientApiCall() {
    isLoading = true;
    ApiService.instance.fetchPatient().then((value) {
      patients = value.data ?? [];
      isLoading = false;
      update([kManagePatient]);
    });
  }

  void addPatientApiCall() {
    Get.back();
    ApiService.instance
        .addPatient(
            image: imageFile,
            age: ageController.text,
            gender: selectGender == S.current.male ? 1 : 0,
            relation: relationController.text,
            fullName: fullNameController.text)
        .then((value) {
      if (value.status == true) {
        CustomUi.snackBar(message: value.message);
      } else {
        CustomUi.snackBar(message: value.message);
      }
      fetchPatientApiCall();
    });
  }

  void pickImage() async {
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

  void onGenderChange(String? value) {
    selectGender = value!;
    update();
  }

  void onContinueTap() {
    bool isValidation = isValid();
    if (isValidation) {
      addPatientApiCall();
    }
  }

  bool isValid() {
    isFullName = false;
    isAge = false;
    isRelation = false;
    int i = 0;
    if (imageFile == null && networkImage == null) {
      i++;
      CustomUi.snackBar(
        message: S.current.pleaseAddYourPhoto,
      );
    }
    if (fullNameController.text.isEmpty) {
      i++;
      isFullName = true;
    }
    if (ageController.text.isEmpty) {
      i++;
      isAge = true;
    }
    if (relationController.text.isEmpty) {
      i++;
      isRelation = true;
    }
    update();
    return i == 0 ? true : false;
  }

  void addNewPatient(ManagePatientScreenController controller) {
    Get.bottomSheet(
            AddPatientSheet(
                controller: controller,
                onContinueTap: onContinueTap,
                screenType: 0),
            isScrollControlled: true)
        .then((value) {
      itemEmpty();
    });
  }

  void editPatient(
      ManagePatientScreenController controller, Patient? patients) {
    fullNameController = TextEditingController(text: patients?.fullname ?? '');
    ageController = TextEditingController(text: patients?.age.toString() ?? '');
    relationController = TextEditingController(text: patients?.relation ?? '');
    selectGender = genders.firstWhere((element) {
      return element ==
          (patients?.gender == 1 ? S.current.male : S.current.female);
    });
    networkImage = patients?.image;
    Get.bottomSheet(
            AddPatientSheet(
                controller: controller,
                onContinueTap: () =>
                    onEditPatientApiCall(patientId: patients?.id),
                screenType: 1),
            isScrollControlled: true)
        .then((value) {
      itemEmpty();
    });
  }

  void onSelectedValue(
      int value, ManagePatientScreenController controller, Patient? patients) {
    if (value == 0) {
      editPatient(controller, patients);
    } else {
      deletePatientApiCall(patientID: patients?.id);
    }
  }

  void deletePatientApiCall({int? patientID}) {
    CustomUi.loader();
    ApiService.instance.deletePatient(patientId: patientID).then((value) {
      Get.back();
      if (value.status == true) {
        CustomUi.snackBar(
          message: value.message!,
        );
        fetchPatientApiCall();
      } else {
        CustomUi.snackBar(
          message: value.message!,
        );
      }
    });
  }

  void onEditPatientApiCall({int? patientId}) {
    Get.back();
    if (isValid()) {
      ApiService.instance
          .editPatient(
              image: imageFile,
              age: ageController.text,
              gender: selectGender == S.current.male ? 1 : 0,
              relation: relationController.text,
              fullName: fullNameController.text,
              patientId: patientId)
          .then((value) {
        if (value.status == true) {
          CustomUi.snackBar(
            message: value.message ?? '',
          );
        } else {
          CustomUi.snackBar(
            message: value.message ?? '',
          );
        }
      }).then((value) {
        fetchPatientApiCall();
      });
    }
  }

  void itemEmpty() {
    fullNameController = TextEditingController();
    ageController = TextEditingController();
    relationController = TextEditingController();
    imageFile = null;
    networkImage = null;
  }

  void prefData() async {
    userData = SessionManager.instance.getUser();
    fetchPatientApiCall();
    update();
  }
}
