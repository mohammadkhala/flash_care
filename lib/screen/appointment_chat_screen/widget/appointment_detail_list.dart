import 'package:flutter/material.dart';
import 'package:patient_flutter/common/animate_expansion.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/appointment/fetch_appointment.dart';
import 'package:patient_flutter/screen/confirm_booking_screen/widget/booking_top_card.dart';
import 'package:patient_flutter/screen/select_date_time_screen/widget/doctor_profile_card.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/font_res.dart';

class AppointmentDetailList extends StatelessWidget {
  final AppointmentData? appointmentData;

  const AppointmentDetailList({super.key, this.appointmentData});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: ListTileTheme(
        dense: true,
        contentPadding: const EdgeInsets.all(0),
        child: ExpansionTile(
          title: Text(
            S.current.appointmentDetails,
            style: const TextStyle(fontFamily: FontRes.medium, color: ColorRes.charcoalGrey, fontSize: 14),
          ),
          collapsedBackgroundColor: ColorRes.whiteSmoke,
          iconColor: ColorRes.davyGrey,
          backgroundColor: ColorRes.white,
          tilePadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
          children: [
            AnimatedExpansion(
              expand: true,
              child: Column(
                children: [
                  DoctorProfileCard(
                    isDividerVisible: false,
                    doctor: appointmentData?.doctor,
                    imageHeight: 70,
                    nameSize: 15,
                    cardColor: true,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(color: ColorRes.whiteSmoke, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        BookingTopCard(
                          title: S.current.date,
                          value: CustomUi.dateFormat(appointmentData?.date),
                        ),
                        BookingTopCard(
                          title: S.current.time,
                          value: CustomUi.convert24HoursInto12Hours(appointmentData?.time),
                        ),
                        BookingTopCard(
                          title: S.current.type,
                          value: appointmentData?.type == 0 ? S.current.online : S.current.clinic,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
