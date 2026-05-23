import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:patient_flutter/screen/select_date_time_screen/select_date_time_screen_controller.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/font_res.dart';
import 'package:patient_flutter/utils/update_res.dart';

class DateBuilder extends StatelessWidget {
  final SelectDateTimeScreenController controller;
  final DateTime day;
  final Color containerColor;
  final VoidCallback onTap;
  final double elevation;

  const DateBuilder(
      {super.key,
      required this.controller,
      required this.day,
      this.containerColor = ColorRes.softPeach,
      this.elevation = 0,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 3),
        elevation: elevation,
        shadowColor: ColorRes.black.withValues(alpha: 0.50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          decoration: BoxDecoration(color: containerColor, borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Row(),
              Text(
                DateFormat(ee, 'en').format(day).toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 0.5,
                  fontFamily: FontRes.medium,
                  color: containerColor == ColorRes.whiteSmoke
                      ? ColorRes.nobel
                      : containerColor == ColorRes.havelockBlue
                          ? ColorRes.white
                          : ColorRes.charcoalGrey,
                ),
              ),
              Text(
                day.day.toString(),
                style: TextStyle(
                  fontSize: 21,
                  fontFamily: FontRes.semiBold,
                  color: containerColor == ColorRes.whiteSmoke
                      ? ColorRes.nobel
                      : containerColor == ColorRes.havelockBlue
                          ? ColorRes.white
                          : ColorRes.charcoalGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
