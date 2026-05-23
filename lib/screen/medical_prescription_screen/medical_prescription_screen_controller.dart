import 'dart:convert';
import 'dart:io';

import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/appointment/appointment_request.dart';
import 'package:doctor_flutter/model/medical_prescription.dart';
import 'package:doctor_flutter/screen/medical_prescription_screen/widget/ad_medical_sheet.dart';
import 'package:doctor_flutter/service/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class MedicalPrescriptionScreenController extends GetxController {
  TextEditingController medicineController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController doseController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController extraNoteController = TextEditingController();
  List<AddMedicine> medicines = [];
  MedicalPrescription? prescription;
  AddMedicine? editMedicine;

  bool isTitleError = false;
  bool isQuantityError = false;
  bool isDosageError = false;
  bool isMealTimeError = false;
  bool isExtraNotesError = false;
  int initialValue = 0;

  List<String> mealList = [S.current.afterMeal, S.current.beforeMeal];
  int? selectedMeal;
  AppointmentData? appointmentData;

  List<HomeExercise> homeProgram = [];
  List<String> attachmentUrls = [];
  List<String> imageUrls = [];
  bool isUploadingFile = false;

  MedicalPrescriptionScreenController(this.appointmentData);

  @override
  void onInit() {
    addPrescription();
    super.onInit();
  }

  void onMealTap(int index) {
    if (selectedMeal == index) {
      selectedMeal = null;
    } else {
      selectedMeal = index;
    }
    update();
  }

  void onSubmitClick(int type) {
    if (isValid()) {
      if (type == 1) {
        var index = medicines.indexOf(editMedicine!);
        medicines[index].title = medicineController.text.trim();
        medicines[index].dosage = doseController.text.trim();
        medicines[index].notes = noteController.text.trim();
        medicines[index].mealTime = selectedMeal;
        medicines[index].quantity = int.parse(quantityController.text);
      } else {
        AddMedicine medicine = AddMedicine(
          title: medicineController.text,
          dosage: doseController.text,
          notes: noteController.text,
          mealTime: selectedMeal,
          quantity: int.parse(quantityController.text),
        );
        medicines.add(medicine);
      }
      Get.back();
    }
  }

  bool isValid() {
    int i = 0;
    falseFiled();
    if (medicineController.text.isEmpty) {
      isTitleError = true;
      return false;
    }
    if (quantityController.text.isEmpty) {
      isQuantityError = true;
      return false;
    }
    if (doseController.text.isEmpty) {
      isDosageError = true;
      return false;
    }
    if (selectedMeal == null) {
      CustomUi.snackBar(message: S.current.pleaseSelectMeal);
      return false;
    }
    return i == 0 ? true : false;
  }

  void onAddHomeExercise(HomeExercise exercise) {
    homeProgram.add(exercise);
    update();
  }

  void onDeleteHomeExercise(HomeExercise exercise) {
    homeProgram.remove(exercise);
    update();
  }

  void onPickAttachment() async {
    if (kIsWeb) return;
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'],
    );
    if (result == null || result.files.isEmpty) return;
    isUploadingFile = true;
    update();
    for (final file in result.files) {
      if (file.path != null) {
        try {
          final uploaded =
              await ApiService.instance.uploadFileGivePath(File(file.path!));
          attachmentUrls.add(uploaded.path ?? '');
        } catch (_) {}
      }
    }
    isUploadingFile = false;
    update();
  }

  void onPickImage() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(imageQuality: 60);
    if (images.isEmpty) return;
    isUploadingFile = true;
    update();
    for (final img in images) {
      try {
        final uploaded =
            await ApiService.instance.uploadFileGivePath(File(img.path));
        imageUrls.add(uploaded.path ?? '');
      } catch (_) {}
    }
    isUploadingFile = false;
    update();
  }

  void onDeleteAttachment(String url) {
    attachmentUrls.remove(url);
    update();
  }

  void onDeleteImage(String url) {
    imageUrls.remove(url);
    update();
  }

  @override
  void onClose() {
    medicineController.clear();
    quantityController.clear();
    doseController.clear();
    noteController.clear();
    super.onClose();
  }

  void falseFiled() {
    isTitleError = false;
    isQuantityError = false;
    isDosageError = false;
    isMealTimeError = false;
    isExtraNotesError = false;
    update();
  }

  void addMedicineTap(MedicalPrescriptionScreenController controller) {
    Get.bottomSheet(AdMedicalSheet(controller: controller, type: 0),
            isScrollControlled: true)
        .then((value) {
      clearText();
    });
  }

  void onContinueTap(int type) {
    if (medicines.isEmpty) {
      CustomUi.snackBar(message: S.current.pleaseAtLeastOneMedicineAdd);
      return;
    }
    if (type == 0) {
      prescription = MedicalPrescription(
        medicines,
        extraNoteController.text.trim(),
        homeProgram: homeProgram.isEmpty ? null : homeProgram,
        attachments: attachmentUrls.isEmpty ? null : attachmentUrls,
        images: imageUrls.isEmpty ? null : imageUrls,
      );
      ApiService.instance
          .addPrescription(
              appointmentId: appointmentData?.id,
              medicine: prescription?.toJson(),
              userId: appointmentData?.userId)
          .then((value) {
        Get.back();
        if (value.status == true) {
          CustomUi.snackBar(message: value.message);
        } else {
          CustomUi.snackBar(message: value.message);
        }
      });
    } else {
      prescription = MedicalPrescription(
        medicines,
        extraNoteController.text.trim(),
        homeProgram: homeProgram.isEmpty ? null : homeProgram,
        attachments: attachmentUrls.isEmpty ? null : attachmentUrls,
        images: imageUrls.isEmpty ? null : imageUrls,
      );
      ApiService.instance
          .editPrescription(
              prescriptionId: appointmentData?.prescription?.id,
              medicine: prescription?.toJson())
          .then((value) {
        Get.back();
        if (value.status == true) {
          CustomUi.snackBar(
            message: value.message,
          );
        } else {
          CustomUi.snackBar(message: value.message);
        }
      });
    }
  }

  void addPrescription() {
    if (appointmentData?.prescription != null) {
      prescription = MedicalPrescription.fromJson(
          jsonDecode(appointmentData?.prescription?.medicine ?? ''));
      medicines = prescription?.addMedicine ?? [];
      homeProgram = prescription?.homeProgram ?? [];
      attachmentUrls = prescription?.attachments ?? [];
      imageUrls = prescription?.images ?? [];
      extraNoteController = TextEditingController(text: prescription?.notes);
    }
  }

  void onMoreBtnClick(AddMedicine addMedicine) {
    medicines.remove(addMedicine);
    update();
  }

  void onDeleteTap(AddMedicine addMedicine) {
    medicines.remove(addMedicine);
    if (medicines.length == 1) {
      deletePrescription();
    } else {
      onContinueTap(1);
    }
    update();
  }

  void deletePrescription() {
    CustomUi.loader();
    ApiService.instance
        .deletePrescription(prescriptionId: appointmentData?.prescription?.id)
        .then((value) {
      if (value.status == true) {
        Get.back();
      } else {
        CustomUi.snackBar(message: value.message);
      }
    });
  }

  void onMedicineEdit(
      AddMedicine addMedicine, MedicalPrescriptionScreenController controller) {
    medicineController = TextEditingController(text: addMedicine.title);
    quantityController =
        TextEditingController(text: addMedicine.quantity.toString());
    doseController = TextEditingController(text: addMedicine.dosage);
    noteController = TextEditingController(text: addMedicine.notes);
    selectedMeal = addMedicine.mealTime;
    editMedicine = addMedicine;
    Get.bottomSheet(AdMedicalSheet(controller: controller, type: 1),
            isScrollControlled: true)
        .then((value) {
      clearText();
    });
  }

  void clearText() {
    medicineController.clear();
    quantityController.clear();
    doseController.clear();
    noteController.clear();
    selectedMeal = null;
    update();
    falseFiled();
  }
}
