import 'package:flutter/material.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/extention.dart';
import 'package:patient_flutter/utils/font_res.dart';
import 'package:patient_flutter/utils/update_res.dart';

class ChatDateFormat extends StatelessWidget {
  final String? time;

  const ChatDateFormat({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        (time ?? milliDate).dateMilliFormat(ddMmmYyyyHhMmA),
        style: const TextStyle(
          fontFamily: FontRes.light,
          fontSize: 12,
          color: ColorRes.davyGrey,
        ),
      ),
    );
  }
}
