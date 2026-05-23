import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextButtonCustom extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final Color? titleColor;
  final Color? backgroundColor;

  const TextButtonCustom({super.key,
      required this.onPressed,
      required this.title,
      required this.titleColor,
      required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: EdgeInsets.zero,
        child: Center(
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              alignment: Alignment.center,
              backgroundColor: backgroundColor ?? ColorRes.havelockBlue,
              minimumSize: Size(Get.width / 1.05, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: titleColor ?? ColorRes.white,
                fontFamily: FontRes.semiBold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
