import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/appointment/fetch_appointment.dart';
import 'package:patient_flutter/screen/dashboard_screen/dashboard_screen.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/utils/asset_res.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class AppointmentBookedScreen extends StatefulWidget {
  final AppointmentData? appointmentData;
  final List<String> scheduledTimes;

  const AppointmentBookedScreen({super.key, this.appointmentData, required this.scheduledTimes});

  @override
  State<AppointmentBookedScreen> createState() => _AppointmentBookedScreenState();
}

class _AppointmentBookedScreenState extends State<AppointmentBookedScreen> {
  @override
  void initState() {
    ApiService.instance.scheduleAppointmentReminders(
        appointmentID: widget.appointmentData?.id ?? -1, scheduledAt: widget.scheduledTimes);
    // for update user in local
    ApiService().fetchMyUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.white,
      body: Column(
        children: [
          Container(
            height: Get.height / 2.6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: ColorRes.havelockBlue.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const Spacer(),
                  Text(
                    S.current.appointmentBooked,
                    style: MyTextStyle.montserratBold(size: 19, color: ColorRes.havelockBlue),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Image.asset(
                    AssetRes.icRoundVerifiedBig,
                    width: Get.width / 4,
                    height: Get.width / 4,
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          const Spacer(
            flex: 2,
          ),
          Text(
            S.current.appointmentID,
            style: MyTextStyle.montserratRegular(
              size: 17,
              color: ColorRes.havelockBlue,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            '${widget.appointmentData?.appointmentNumber}'.toUpperCase(),
            style: MyTextStyle.montserratExtraBold(
              size: 19,
              color: ColorRes.havelockBlue,
            ),
          ),
          const Spacer(
            flex: 2,
          ),
          Text(
            S.current.yourAppointmentHasEtc,
            textAlign: TextAlign.center,
            style: MyTextStyle.montserratBold(
              size: 20,
              color: ColorRes.davyGrey,
            ),
          ),
          const Spacer(),
          Text(
            S.current.checkAppointmentsEtc,
            textAlign: TextAlign.center,
            style: MyTextStyle.montserratRegular(
              color: ColorRes.battleshipGrey,
            ),
          ),
          const Spacer(
            flex: 5,
          ),
          InkWell(
            onTap: () {
              Get.offAll(() => const DashboardScreen());
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              decoration: const BoxDecoration(gradient: MyTextStyle.linearTopGradient),
              child: SafeArea(
                top: false,
                child: Text(
                  S.current.myAppointments,
                  style: MyTextStyle.montserratSemiBold(size: 17, color: ColorRes.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
