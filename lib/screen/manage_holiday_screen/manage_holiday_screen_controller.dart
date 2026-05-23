import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/service/api_service.dart';
import 'package:doctor_flutter/utils/update_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ManageHolidayScreenController extends GetxController {
  List<Holidays>? holidays;
  bool isLoading = false;

  @override
  void onInit() {
    fetchDoctorApiCall();
    super.onInit();
  }

  void onDatePickerOpen() async {
    DateTime? pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate:
          DateTime.utc(DateTime.now().year + 3, DateTime.now().month).subtract(
        const Duration(days: 1),
      ),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat(yyyyMmDd, 'en').format(pickedDate);
      ApiService.instance.addHoliday(date: formattedDate).then((value) {
        if (value.status == true) {
          fetchDoctorApiCall();

          CustomUi.snackBar(message: value.message);
        } else {
          CustomUi.snackBar(message: value.message);
        }
      });
    } else {}
  }

  void onHolidayDeleteTap(Holidays? holiday) {
    holidays?.remove(holiday);
    ApiService.instance.deleteHoliday(holidayId: holiday?.id).then((value) {
      if (value.status == true) {
        fetchDoctorApiCall();
        CustomUi.snackBar(message: value.message);
      } else {
        CustomUi.snackBar(message: value.message);
      }
    });
    update();
  }

  void fetchDoctorApiCall() {
    isLoading = true;
    ApiService.instance.fetchMyDoctorProfile().then((value) {
      holidays = value.data?.holidays;
      isLoading = false;
      update();
    });
  }
}
