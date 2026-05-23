import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/screen/services_screen/widget/bottom_sheet_one_text_field.dart';
import 'package:doctor_flutter/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServicesScreenController extends GetxController {
  TextEditingController serviceController = TextEditingController();
  DoctorData? registrationData;
  bool isLoading = false;

  @override
  void onInit() {
    doctorProfileApiCall();
    super.onInit();
  }

  void doctorProfileApiCall() async {
    isLoading = true;
    ApiService.instance.fetchMyDoctorProfile().then((value) {
      registrationData = value.data;
      isLoading = false;
      update();
    });
  }

  void onAddBtnTap({int? apiType, int? id, required int screenType}) async {
    if (serviceController.text.isEmpty) {
      CustomUi.snackBarMaterial(apiType == 1 ? S.current.pleaseAddServices : S.current.pleaseEditServices);
      return;
    }

    CustomUi.loader();

    try {
      Registration value;

      switch (screenType) {
        case 0:
          value =
              await ApiService.instance.addEditService(apiType: apiType, title: serviceController.text, serviceId: id);
          break;
        case 1:
          value = await ApiService.instance
              .addEditExpertise(apiType: apiType, title: serviceController.text, expertiseId: id);
          break;
        case 2:
          value = await ApiService.instance
              .addEditExperience(apiType: apiType, title: serviceController.text, experienceId: id);
          break;
        case 3:
          value = await ApiService.instance.addEditAwards(apiType: apiType, title: serviceController.text, awardId: id);
          break;
        default:
          return;
      }

      Get.back();

      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }

      CustomUi.snackBarMaterial(value.message);

      if (value.status == true) {
        registrationData = value.data;
        update();
      }
    } catch (e) {
      Get.back();
      CustomUi.snackBarMaterial(S.current.somethingWentWrong);
    }
  }

  void onServiceSheetOpen({required int screenType, int? apiType, int? id, required bool isAdd}) {
    if (isAdd) {
      serviceController.clear();
    }
    Get.bottomSheet(
      BottomSheetOneTextField(
        onTap: () => onAddBtnTap(apiType: apiType, id: id, screenType: screenType),
        title: "${isAdd ? S.current.add : S.current.edit} ${_getTitleForScreenType(screenType)}",
        controller: serviceController,
      ),
      isScrollControlled: true,
    ).then((value) {
      serviceController.clear();
    });
  }

  String _getTitleForScreenType(int screenType) {
    switch (screenType) {
      case 0:
        return S.current.services;
      case 1:
        return S.current.expertise;
      case 2:
        return S.current.experience;
      case 3:
        return S.current.awards;
      default:
        return '';
    }
  }
}
