import 'package:doctor_flutter/model/appointment/appointment_request.dart';
import 'package:doctor_flutter/screen/appointment_detail_screen/appointment_detail_screen.dart';
import 'package:doctor_flutter/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequestScreenController extends GetxController {
  int? start = 0;
  RxBool isLoading = false.obs;
  ScrollController requestController = ScrollController();

  RxList<AppointmentData> appointment = <AppointmentData>[].obs;

  void initData() {
    fetchAppointmentRequestApiCall();
    scrollToFetchData();
  }

  void fetchAppointmentRequestApiCall() {
    isLoading.value = true;
    ApiService.instance
        .fetchAppointmentRequests(start: appointment.length)
        .then((value) {
      appointment.addAll(value.data ?? []);
      isLoading.value = false;
      update();
    });
  }

  void scrollToFetchData() {
    requestController.addListener(
      () {
        if (requestController.offset ==
                requestController.position.maxScrollExtent &&
            !isLoading.value) {
          fetchAppointmentRequestApiCall();
        }
      },
    );
  }

  void onViewTap(AppointmentData? data) {
    Get.to(() => AppointmentDetailScreen(
        onUpdate: (status, data) {
          appointment.removeWhere((element) => element.id == data?.id);
        },
        appointmentData: data));
  }
}
