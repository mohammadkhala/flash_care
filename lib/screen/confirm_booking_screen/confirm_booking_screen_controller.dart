import 'package:get/get.dart';
import 'package:patient_flutter/common/common_fun.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/model/appointment/coupon.dart';
import 'package:patient_flutter/model/custom/categories.dart';
import 'package:patient_flutter/model/custom/order_summary.dart';
import 'package:patient_flutter/model/doctor/fetch_doctor.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/screen/appointment_booked_screen/appointment_booked_screen.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/services/session_manager.dart';

class ConfirmBookingScreenController extends GetxController {
  List<CouponData>? coupons;
  AppointmentDetail? appointmentDetail;
  CouponData? selectedCoupon;
  DoctorData? doctorData;
  num serviceAmount = 0;
  Rx<UserData?> userData = Rx(null);

  @override
  void onInit() {
    appointmentDetail = Get.arguments[0];
    doctorData = Get.arguments[1];
    prefData();
    super.onInit();
  }

  void prefData() async {
    userData.value = SessionManager.instance.getUser();
    serviceAmount = (appointmentDetail?.serviceAmount ?? 0);
    update();
  }

  void onConfirmBooking() {
    OrderSummary orderSummary = OrderSummary(
      discountAmount: 0,
      coupon: null,
      couponApply: 0,
      payableAmount: 0,
      serviceAmount: serviceAmount,
      subtotal: serviceAmount,
      totalTaxAmount: 0,
      taxes: [],
    );
    List<String> scheduleTimes = [];
    try {
      scheduleTimes = CommonFun.sendScheduledAtTime(
        date: appointmentDetail?.date ?? '',
        time: appointmentDetail?.time ?? '',
      );
    } catch (_) {}

    CustomUi.loader();
    ApiService.instance
        .addAppointment(
            doctorId: doctorData?.id,
            problem: appointmentDetail?.problem ?? '',
            date: appointmentDetail?.date ?? '',
            time: appointmentDetail?.time ?? '',
            patientId: appointmentDetail?.patientId,
            orderSummary: orderSummary,
            payableAmount: 0,
            documents: appointmentDetail?.documents,
            type: appointmentDetail?.type,
            isCouponApplied: 0,
            discountAmount: 0,
            totalTaxAmount: 0,
            serviceAmount: serviceAmount,
            subTotal: serviceAmount)
        .then((value) {
      Get.back();
      if (value.status == true) {
        CustomUi.snackBar(message: value.message);
        Get.offAll(
            () => AppointmentBookedScreen(
                  appointmentData: value.data,
                  scheduledTimes: scheduleTimes,
                ),
            arguments: value.data);
      } else {
        CustomUi.snackBar(message: value.message);
      }
    });
  }
}
