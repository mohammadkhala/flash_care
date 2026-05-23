import 'package:doctor_flutter/common/confirmation_dialog.dart';
import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/appointment_slot/appointment_slot.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/screen/appointment_slots_screen/widget/add_slot_dialog.dart';
import 'package:doctor_flutter/service/api_service.dart';
import 'package:doctor_flutter/utils/update_res.dart';
import 'package:get/get.dart';

// 1 monday

class AppointmentSlotsScreenController extends GetxController {
  List<AppointmentSlot> appointmentSlot = [
    AppointmentSlot(S.current.monday, []),
    AppointmentSlot(S.current.tuesday, []),
    AppointmentSlot(S.current.wednesday, []),
    AppointmentSlot(S.current.thursday, []),
    AppointmentSlot(S.current.friday, []),
    AppointmentSlot(S.current.saturday, []),
    AppointmentSlot(S.current.sunday, [])
  ];

  bool isLoading = false;
  DoctorData? registrationData;
  final now = DateTime.now();

  @override
  void onInit() {
    fetchDoctorApiCall();
    super.onInit();
  }

  void fetchDoctorApiCall() {
    isLoading = true;
    ApiService.instance.fetchMyDoctorProfile().then((value) {
      registrationData = value.data;
      registrationData?.slots?.forEach((element) {
        appointmentSlot[(element.weekday! - 1)].time.add(element);
      });
      isLoading = false;
      update();
    });
  }

  void addBtnTap(int weekIndex) {
    Get.dialog(AddSlotDialog(
      daysIndex: weekIndex,
      appointmentSlot: appointmentSlot,
    )).then((value) {
      update();
    });
  }

  void deleteSlot(Slots? time) {
    Get.dialog(ConfirmationDialog(
      title1: S.current.deleteAppointmentSlot,
      title2: S.current.areYouSureYouWantToDeleteThisAppointmentSlot,
      positiveText: S.current.delete,
      aspectRatio: 1.7,
      onPositiveTap: () {
        CustomUi.loader();
        ApiService.instance
            .deleteAppointmentSlot(slotId: time?.id)
            .then((value) {
          Get.back();
          appointmentSlot[time!.weekday! - 1].time.removeWhere((element) {
            return element?.time == time.time;
          });
          update([kAppointmentDelete]);
        });
      },
    ));
  }
}
