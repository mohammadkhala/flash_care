import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/screen/appointment_screen/appointment_screen_controller.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:flutter/material.dart';

class TopBarAreaAppointment extends StatelessWidget {
  final AppointmentScreenController controller;

  const TopBarAreaAppointment({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
      color: ColorRes.whiteSmoke,
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(S.current.appointments.toUpperCase(),
                  style: const TextStyle(
                      color: ColorRes.charcoalGrey, fontSize: 17)),
            ),
          ],
        ),
      ),
    );
  }
}
