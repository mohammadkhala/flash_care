import 'package:doctor_flutter/common/common_fun.dart';
import 'package:doctor_flutter/model/appointment/appointment_request.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/screen/appointment_screen/widget/select_month_dialog.dart';
import 'package:doctor_flutter/service/api_service.dart';
import 'package:doctor_flutter/service/session_manager.dart';
import 'package:doctor_flutter/utils/extention.dart';
import 'package:doctor_flutter/utils/update_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AppointmentScreenController extends GetxController {
  Rx<DateTime> selectedDay = DateTime.now().obs;

  RxBool isLoading = false.obs;

  RxList<AppointmentData> acceptAppointment = RxList();
  RxList<AppointmentData> filterAppointment = RxList();

  TextEditingController searchController = TextEditingController();
  ScrollController dateController = ScrollController();

  DoctorData? doctorData;

  RxList<DateTime> days = List<DateTime>.generate(
      90,
      (i) => DateTime.utc(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          ).add(Duration(hours: 24 * i))).obs;

  @override
  void onInit() {
    prefData();
    fetchAcceptedAppointsByDateApiCall(date: selectedDay.value);
    super.onInit();
  }

  void getDays({required int year, required int month}) {
    days.value = [];
    days.value = List<DateTime>.generate(
        90,
        (i) => DateTime.utc(
              year,
              month,
            ).add(Duration(hours: 24 * i)));
  }

  void onDoneClick(int month, int year) {
    CommonFun.doctorBanned(() {
      getDays(year: year, month: month);

      onSelectedDateClick(
          dateTime: DateTime(year, month, selectedDay.value.day),
          index: days.indexWhere(
            (element) => element.isSameDate(
              DateTime(year, month, selectedDay.value.day),
            ),
          ));
    });
  }

  void onSelectedDateClick({required DateTime dateTime, required int index}) {
    if (selectedDay.value == dateTime) return;

    CommonFun.doctorBanned(() {
      selectedDay.value = dateTime;
      fetchAcceptedAppointsByDateApiCall(date: selectedDay.value);
      if (dateController.offset < dateController.position.maxScrollExtent) {
        dateController.animateTo(index * (63 + 8),
            duration: const Duration(milliseconds: 300), curve: Curves.linear);
      }
    });
  }

  void fetchAcceptedAppointsByDateApiCall({required DateTime date}) async {
    isLoading.value = true;
    ApiService.instance
        .fetchAcceptedAppointsByDate(
            date: DateFormat(yyyyMmDd, 'en').format(date))
        .then((value) {
      acceptAppointment.value = value.data ?? [];
      filterAppointment.value = value.data ?? [];
      isLoading.value = false;
      update();
    }).catchError((e) {
      isLoading.value = false;
      update();
    });
  }

  void onSearchChanged(String value) {
    if (searchController.text.isEmpty) {
      filterAppointment = acceptAppointment;
    } else {
      filterAppointment.value = acceptAppointment
          .where((element) => (element.user?.fullname ?? '')
              .isCaseInsensitiveContains(searchController.text))
          .toList();
    }
    update();
  }

  void prefData() async {
    doctorData = SessionManager.instance.getDoctor();
    update();
  }

  void onAppointmentBoxTap() {
    CommonFun.doctorBanned(() {
      showDialog(
        context: Get.context!,
        builder: (context) => SelectMonthDialog(
          onDoneClick: onDoneClick,
          month: selectedDay.value.month,
          year: selectedDay.value.year,
        ),
      );
    });
  }
}
