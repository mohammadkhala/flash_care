import 'package:flutter/material.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class DashboardTopBarTitle extends StatelessWidget {
  final String title;

  const DashboardTopBarTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      color: ColorRes.whiteSmoke,
      width: double.infinity,
      child: SafeArea(
        bottom: false,
        child: Text(
          title.toUpperCase(),
          style: MyTextStyle.montserratRegular(size: 17, color: ColorRes.charcoalGrey),
        ),
      ),
    );
  }
}
