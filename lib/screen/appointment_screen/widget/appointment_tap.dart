import 'package:flutter/material.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class AppointmentTab extends StatelessWidget {
  final Color color;
  final double topRight;
  final double bottomRight;
  final double topLeft;
  final double bottomLeft;
  final Color titleColor;
  final String title;
  final VoidCallback onTap;

  const AppointmentTab({
    super.key,
    this.color = ColorRes.whiteSmoke,
    required this.title,
    required this.onTap,
    this.topRight = 0,
    this.bottomRight = 0,
    this.topLeft = 0,
    this.bottomLeft = 0,
    this.titleColor = ColorRes.white,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(topRight),
                bottomRight: Radius.circular(bottomRight),
                topLeft: Radius.circular(topLeft),
                bottomLeft: Radius.circular(bottomLeft)),
          ),
          alignment: Alignment.center,
          height: 45,
          child: Text(
            title,
            style: MyTextStyle.montserratRegular(size: 16, color: titleColor),
          ),
        ),
      ),
    );
  }
}
