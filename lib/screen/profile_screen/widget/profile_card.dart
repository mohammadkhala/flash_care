import 'package:flutter/material.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class ProfileCard extends StatelessWidget {
  final String title;
  final Color cardColor;
  final Color textColor;
  final VoidCallback onTap;

  const ProfileCard(
      {super.key,
      required this.title,
      this.cardColor = ColorRes.whiteSmoke,
      this.textColor = ColorRes.davyGrey,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 3),
        padding: const EdgeInsets.all(15),
        alignment: Directionality.of(context) == TextDirection.rtl
            ? Alignment.centerRight
            : Alignment.centerLeft,
        color: cardColor,
        child: Text(
          title,
          style: MyTextStyle.montserratRegular(size: 16, color: textColor),
        ),
      ),
    );
  }
}
