import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/screen/profile_screen/profile_screen_controller.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:flutter/material.dart';

class EducationPage extends StatelessWidget {
  final ProfileScreenController? controller;

  const EducationPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Text(
        controller?.doctorData.value?.educationalJourney ?? S.current.noData,
        style: const TextStyle(
            fontSize: 15,
            color: ColorRes.mediumGrey,
            fontFamily: FontRes.regular),
      ),
    );
  }
}
