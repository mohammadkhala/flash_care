import 'package:get/get.dart';
import 'package:patient_flutter/model/appointment/fetch_appointment.dart';
import 'package:patient_flutter/screen/appointment_detail_screen/appointment_detail_screen.dart';
import 'package:patient_flutter/services/api_service.dart';

class AppointmentScreenController extends GetxController {
  RxList<AppointmentData> appointmentData = RxList([]);
  List<AppointmentData> tampList = [];
  RxBool isLoading = true.obs;
  List<String> appointmentFilters = ['All', 'Upcoming', 'Completed'];
  RxInt selectedIndex = 0.obs;

  @override
  void onInit() {
    fetchAppointmentData();
    super.onInit();
  }

  void fetchAppointmentData() async {
    isLoading.value = true;
    ApiService.instance.fetchMyAppointments().then((value) {
      tampList.addAll(value.data ?? []);
      appointmentData.addAll(value.data ?? []);
      isLoading.value = false;
      update();
    }).catchError((e) {
      isLoading.value = false;
      update();
    });
  }

  onAppointmentCardTap(AppointmentData? data) {
    Get.to(() => const AppointmentDetailScreen(), arguments: data)
        ?.then((value) {
      appointmentData.value = [];
      tampList = [];
      selectedIndex.value = 0;
      fetchAppointmentData();
    });
  }

  onTabChanged(int index) {
    if (selectedIndex.value == index) return;
    selectedIndex.value = index;
    appointmentData.value = [];
    if (index == 0) {
      for (var element in tampList) {
        appointmentData.add(element);
      }
    } else if (index == 1) {
      for (var element in tampList) {
        if (element.status == 1) {
          appointmentData.add(element);
        }
      }
    } else if (index == 2) {
      for (var element in tampList) {
        if (element.status == 2) {
          appointmentData.add(element);
        }
      }
    }
  }
}
