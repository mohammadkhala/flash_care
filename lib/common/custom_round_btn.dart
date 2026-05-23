import 'package:doctor_flutter/utils/asset_res.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomRoundBtn extends StatelessWidget {
  final double? iconSize;
  final Color? iconColor;
  final Color? bgColor;

  const CustomRoundBtn(
      {super.key, this.iconSize, this.iconColor, this.bgColor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Get.back();
        },
        child: Container(
          height: iconSize ?? 35,
          width: iconSize ?? 35,
          alignment: const Alignment(0, 0),
          decoration: BoxDecoration(
            color: bgColor ?? ColorRes.iceberg,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Image.asset(
            AssetRes.icClose,
            height: (iconSize ?? 35) / 2,
            width: (iconSize ?? 35) / 2,
            color: iconColor ?? ColorRes.charcoalGrey,
          ),
        ));
  }
}
