import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/utils/color_res.dart';

class CloseButtonCustom extends StatelessWidget {
  final Color? bgColor;
  final Color? iconColor;
  final double? size;

  const CloseButtonCustom({super.key, this.bgColor, this.iconColor, this.size});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.back();
      },
      child: Container(
        height: size ?? 37,
        width: size ?? 37,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: bgColor ?? ColorRes.havelockBlue.withValues(alpha: 0.1)),
        child: Icon(
          Icons.close_rounded,
          color: iconColor ?? ColorRes.charcoalGrey,
          size: 18,
        ),
      ),
    );
  }
}
