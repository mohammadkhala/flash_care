import 'package:doctor_flutter/common/confirmation_dialog.dart';
import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/appointment/appointment_request.dart';
import 'package:doctor_flutter/model/custom/order_summary.dart';
import 'package:doctor_flutter/screen/appointment_chat_screen/appointment_chat_screen.dart';
import 'package:doctor_flutter/screen/appointment_detail_screen/widget/mark_complete_sheet.dart';
import 'package:doctor_flutter/screen/medical_prescription_screen/medical_prescription_screen.dart';
import 'package:doctor_flutter/screen/previous_appointment_screen/previous_appointment_screen.dart';
import 'package:doctor_flutter/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum AppointmentStatus { accept, decline }

class AppointmentDetailScreenController extends GetxController {
  TextEditingController diagnosedController = TextEditingController();
  TextEditingController completionOtpController = TextEditingController();
  bool isLoading = false;
  bool isDiagnosed = false;
  bool isCompletionOtp = false;
  Rx<AppointmentData?> appointmentData = Rx(null);
  RxBool isExpanded = false.obs;
  OrderSummary? orderSummary;
  Function(AppointmentStatus status, AppointmentData? data)? onUpdate;

  AppointmentDetailScreenController(
      this.onUpdate, AppointmentData? appointmentData) {
    this.appointmentData.value = appointmentData;
  }

  @override
  void onInit() {
    fetchAppointmentDetailsApiCall();
    super.onInit();
  }

  void onExpandTap(bool value) {
    isExpanded.value = value;
    update();
  }

  void onAcceptBtnTap(AppointmentData? data) {
    CustomUi.loader();
    ApiService.instance
        .acceptAppointment(appointmentId: data?.id, doctorId: data?.doctorId)
        .then((value) {
      Get.back();
      if (value.status == true) {
        onUpdate?.call(AppointmentStatus.accept, data);
        fetchAppointmentDetailsApiCall();
        CustomUi.snackBar(message: value.message);
      } else {
        CustomUi.snackBar(message: value.message);
      }
    });
  }

  void fetchAppointmentDetailsApiCall() {
    isLoading = true;
    ApiService.instance
        .fetchAppointmentDetails(appointmentId: appointmentData.value?.id)
        .then((value) {
      appointmentData.value = value.data;
      isLoading = false;
      update();
    });
  }

  void onDeclineBtnTap(AppointmentData? data) {
    Get.dialog(
      ConfirmationDialog(
        onPositiveTap: () {
          CustomUi.loader();
          ApiService.instance
              .declineAppointment(
                  appointmentId: data?.id, doctorId: data?.doctorId)
              .then((value) {
            Get.back();
            Get.back();
            CustomUi.snackBar(message: value.message);
            if (value.status == true) {
              onUpdate?.call(AppointmentStatus.accept, data);
            }
          });
        },
        title1: S.current.declineAppointment,
        title2: S.current.areYouSureYouWantToDeclineThisAppointmentThis,
        positiveText: S.current.delete,
        aspectRatio: 1 / 0.65,
      ),
    );
  }

  void onMedicalPrescriptionTap() {
    Get.to(() =>
            MedicalPrescriptionScreen(appointmentData: appointmentData.value))
        ?.then((value) {
      fetchAppointmentDetailsApiCall();
    });
  }

  void onMarkCompleteTap(AppointmentDetailScreenController controller) {
    Get.bottomSheet(
            MarkCompleteSheet(
                onTap: completeAppointmentApiCall, controller: controller),
            isScrollControlled: true)
        .then((value) {
      diagnosedController.text = '';
      completionOtpController.text = '';
      isDiagnosed = false;
      isCompletionOtp = false;
      fetchAppointmentDetailsApiCall();
    });
  }

  void completeAppointmentApiCall() {
    isDiagnosed = false;
    isCompletionOtp = false;
    update();
    if (diagnosedController.text.isEmpty) {
      isDiagnosed = true;
      return;
    }
    if (completionOtpController.text.isEmpty) {
      isCompletionOtp = true;
      return;
    }
    ApiService.instance
        .completeAppointment(
            appointmentId: appointmentData.value?.id,
            doctorId: appointmentData.value?.doctorId,
            otp: completionOtpController.text,
            diagnoseWith: diagnosedController.text)
        .then(
      (value) {
        Get.back();
        if (value.status == true) {
          CustomUi.snackBar(message: value.message);
        } else {
          CustomUi.snackBar(message: value.message);
        }
      },
    );
  }

  void onPreviousAppointmentTap() {
    Get.to(() =>
        PreviousAppointmentScreen(appointmentData: appointmentData.value));
  }

  void onMessageBtnTap() {
    Get.to(() => AppointmentChatScreen(appointmentData: appointmentData.value));
  }
}
