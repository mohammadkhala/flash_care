import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/confirmation_dialog.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/appointment/fetch_appointment.dart';
import 'package:patient_flutter/model/custom/order_summary.dart';
import 'package:patient_flutter/screen/appointment_detail_screen/widget/rating_sheet.dart';
import 'package:patient_flutter/screen/select_date_time_screen/select_date_time_screen.dart';
import 'package:patient_flutter/services/api_service.dart';

class AppointmentDetailScreenController extends GetxController {
  TextEditingController ratingController = TextEditingController();
  AppointmentData? appointmentData;
  OrderSummary? orderSummary;
  bool isLoading = false;
  double? ratingCount;
  bool isExpanded = false;

  @override
  void onInit() {
    appointmentData = Get.arguments;

    fetchAppointmentDetailsApiCall();
    super.onInit();
  }

  void onRatingTap(AppointmentDetailScreenController controller) {
    Get.bottomSheet(
            RatingSheet(
              controller: controller,
              onRatingTap: (rating) {
                ratingCount = rating;
              },
              onRatingSubmit: () {
                if (ratingCount == null) {
                  return CustomUi.snackBar(
                    message: S.current.pleaseAtLeastRatingAdd,
                  );
                }
                if (ratingController.text.isEmpty) {
                  return CustomUi.snackBar(
                    message: S.current.pleaseAddComment,
                  );
                }
                ApiService.instance
                    .addRating(
                        appointmentId: appointmentData?.id,
                        comment: ratingController.text,
                        rating: ratingCount?.toInt(),
                        userId: appointmentData?.userId)
                    .then(
                  (value) {
                    if (value.status == true) {
                      Get.back();
                      CustomUi.snackBar(
                        message: value.message,
                      );
                      appointmentData = value.data;
                      update();
                    } else {
                      CustomUi.snackBar(
                        message: value.message ?? '',
                      );
                    }
                  },
                );
              },
            ),
            isScrollControlled: true)
        .then((value) {
      ratingCount = null;
      ratingController.text = '';
    });
  }

  void onRatingChange(String value) {
    update();
  }

  void onExpandTap(bool value) {
    isExpanded = value;
    update();
  }

  void fetchAppointmentDetailsApiCall() {
    isLoading = true;
    ApiService.instance
        .fetchAppointmentDetails(appointmentId: appointmentData?.id)
        .then((value) {
      appointmentData = value.data;
      isLoading = false;
      update();
    });
  }

  void onRescheduleTap(AppointmentData? data) {
    Get.dialog(ConfirmationDialog(
      onPositiveTap: () {
        Get.to(() => const SelectDateTimeScreen(addAppointment: 1),
            arguments: [data?.doctor, data])?.then((value) {
          fetchAppointmentDetailsApiCall();
        });
      },
      title1: S.current.rescheduleAppointment,
      title2: S.current.areYouSureYouWantToRescheduleYourDoctorAppointment,
      positiveText: S.current.yes,
      aspectRatio: 1.4,
    ));
  }

  onCancelBtnClick(AppointmentData? data) {
    Get.dialog(ConfirmationDialog(
      onPositiveTap: () {
        CustomUi.loader();
        ApiService.instance
            .cancelAppointment(appointmentId: data?.id, userId: data?.userId)
            .then((value) {
          Get.back();
          if (value.status == true) {
            appointmentData = value.data;
            CustomUi.snackBar(message: value.message ?? '');
            update();
          } else {
            CustomUi.snackBar(message: value.message ?? '');
          }
        });
      },
      title1: S.current.cancelAppointment,
      title2: S.current.areYouSureYouWantToCancelYourDoctorAppointment,
      positiveText: S.current.cancel,
      aspectRatio: 1.3,
    ));
  }
}
