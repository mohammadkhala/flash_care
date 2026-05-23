import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class TextButtonCustom extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final Color titleColor;
  final Color backgroundColor;
  final double bottomMargin;
  final bool bottomSafeArea;

  const TextButtonCustom(
      {super.key,
      required this.onPressed,
      required this.title,
      required this.titleColor,
      required this.backgroundColor,
      this.bottomMargin = 0,
      this.bottomSafeArea = true});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: bottomSafeArea,
      child: Container(
        margin: EdgeInsets.only(bottom: bottomMargin),
        child: Center(
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              alignment: Alignment.center,
              backgroundColor: backgroundColor,
              minimumSize: Size(Get.width / 1.1, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(title, style: MyTextStyle.montserratSemiBold(size: 15, color: titleColor)),
          ),
        ),
      ),
    );
  }
}
