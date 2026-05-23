import 'package:flutter/material.dart';
import 'package:patient_flutter/screen/doctor_profile_screen/doctor_profile_screen_controller.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class EducationPage extends StatelessWidget {
  final DoctorProfileScreenController controller;

  const EducationPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Text(
        controller.doctorData?.educationalJourney ?? '',
        style: MyTextStyle.montserratRegular(size: 15, color: ColorRes.battleshipGrey),
      ),
    );
  }
}
