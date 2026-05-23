import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/top_bar_area.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/confirm_booking_screen/confirm_booking_screen_controller.dart';
import 'package:patient_flutter/screen/confirm_booking_screen/widget/appointment_booking_card.dart';
import 'package:patient_flutter/screen/select_date_time_screen/widget/doctor_profile_card.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class ConfirmBookingScreen extends StatelessWidget {
  const ConfirmBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ConfirmBookingScreenController());
    return Scaffold(
      backgroundColor: ColorRes.white,
      body: Column(
        children: [
          TopBarArea(title: S.current.confirmBooking),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DoctorProfileCard(doctor: controller.doctorData),
                  GetBuilder(
                    init: controller,
                    builder: (context) {
                      return AppointmentBookingCard(
                        coupons: controller.coupons,
                        detail: controller.appointmentDetail,
                        controller: controller,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: controller.onConfirmBooking,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: const BoxDecoration(
                gradient: MyTextStyle.linearTopGradient,
              ),
              alignment: Alignment.center,
              child: SafeArea(
                top: false,
                child: Text(
                  S.current.confirmBooking,
                  style: MyTextStyle.montserratSemiBold(
                      size: 17, color: ColorRes.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
