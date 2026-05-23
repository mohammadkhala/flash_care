import 'package:doctor_flutter/model/appointment/appointment_request.dart';
import 'package:doctor_flutter/screen/appointment_detail_screen/appointment_detail_screen.dart';
import 'package:doctor_flutter/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppointmentHistoryScreenController extends GetxController {
  int? start = 0;
  bool isLoading = false;
  List<AppointmentData>? appointmentData;
  ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    fetchAppointmentHistoryApiCall();
    fetchScrollData();
    super.onInit();
  }

  void fetchAppointmentHistoryApiCall() {
    isLoading = true;
    ApiService.instance.fetchAppointmentHistory(start: start).then((value) {
      if (start == 0) {
        appointmentData = value.data;
      } else {
        appointmentData?.addAll(value.data!);
      }
      start = appointmentData?.length;
      isLoading = false;
      update();
    });
  }

  void fetchScrollData() {
    scrollController.addListener(() {
      if (scrollController.offset ==
          scrollController.position.maxScrollExtent) {
        if (!isLoading) {
          fetchAppointmentHistoryApiCall();
        }
      }
    });
  }

  void onAppointmentCardTap(AppointmentData? appointmentData) {
    Get.to(() => AppointmentDetailScreen(appointmentData: appointmentData))
        ?.then((value) {
      start == 0;
      fetchAppointmentHistoryApiCall();
    });
  }
}
