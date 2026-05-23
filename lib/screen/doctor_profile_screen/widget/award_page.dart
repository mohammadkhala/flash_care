import 'package:flutter/material.dart';
import 'package:patient_flutter/model/doctor/fetch_doctor.dart';
import 'package:patient_flutter/screen/doctor_profile_screen/doctor_profile_screen_controller.dart';
import 'package:patient_flutter/utils/asset_res.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class AwardPage extends StatelessWidget {
  final DoctorProfileScreenController controller;

  const AwardPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      primary: false,
      shrinkWrap: true,
      itemCount: controller.doctorData?.awards?.length ?? 0,
      itemBuilder: (context, index) {
        Services? awards = controller.doctorData?.awards?[index];
        return Container(
          color: ColorRes.whiteSmoke,
          padding: const EdgeInsets.all(15),
          margin: const EdgeInsets.symmetric(vertical: 1.5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                AssetRes.icAward,
                width: 15,
                height: 20,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  awards?.title ?? '',
                  style: MyTextStyle.montserratRegular(size: 14, color: ColorRes.davyGrey),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
