import 'package:flutter/material.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class SwitchCard extends StatelessWidget {
  final String title;
  final String title2;
  final AlignmentGeometry alignment;
  final bool enable;
  final VoidCallback onTap;
  final VoidCallback onNotificationTap;

  const SwitchCard(
      {super.key,
      required this.title,
      required this.title2,
      required this.alignment,
      required this.enable,
      required this.onTap,
      required this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorRes.whiteSmoke,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onNotificationTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: MyTextStyle.montserratMedium(size: 15, color: ColorRes.charcoalGrey),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    title2,
                    style: MyTextStyle.montserratRegular(size: 12.5, color: ColorRes.battleshipGrey),
                  )
                ],
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: onTap,
            child: AnimatedContainer(
              height: 25,
              width: 40,
              padding: const EdgeInsets.symmetric(horizontal: 3.5),
              alignment: alignment,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: enable
                    ? MyTextStyle.linearTopGradient
                    : const LinearGradient(
                        colors: [ColorRes.grey, ColorRes.grey],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter),
              ),
              duration: const Duration(milliseconds: 250),
              child: Container(
                height: 19,
                width: 19,
                decoration: const BoxDecoration(
                  color: ColorRes.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
