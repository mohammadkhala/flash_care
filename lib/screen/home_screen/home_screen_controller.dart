import 'package:doctor_flutter/model/appointment/appointment_request.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/service/api_service.dart';
import 'package:doctor_flutter/service/session_manager.dart';
import 'package:doctor_flutter/utils/update_res.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeScreenController extends GetxController {
  DoctorData? doctorData;
  RxBool isLoading = false.obs;
  RxList<AppointmentData> todayAppointments = RxList();

  @override
  void onInit() {
    prefData();
    fetchTodayAppointments();
    super.onInit();
  }

  void prefData() {
    doctorData = SessionManager.instance.getDoctor();
    update();
  }

  void fetchTodayAppointments() {
    isLoading.value = true;
    ApiService.instance
        .fetchAcceptedAppointsByDate(
            date: DateFormat(yyyyMmDd, 'en').format(DateTime.now()))
        .then((value) {
      todayAppointments.value = value.data ?? [];
      isLoading.value = false;
      update();
    }).catchError((e) {
      isLoading.value = false;
      update();
    });
  }
}
