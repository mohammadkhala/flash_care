import 'package:flutter/material.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class SpecialistsTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final VoidCallback onCloseBtnTap;

  const SpecialistsTopBar({
    super.key,
    required this.title,
    required this.onTap,
    required this.onCloseBtnTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: const BoxDecoration(gradient: MyTextStyle.linearBottomGradient),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: onCloseBtnTap,
              child: Container(
                height: 37,
                width: 37,
                decoration: BoxDecoration(
                    color: ColorRes.white.withValues(alpha: 0.10), shape: BoxShape.circle),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: ColorRes.white,
                ),
              ),
            ),
            Text(
              title,
              style: MyTextStyle.montserratSemiBold(color: ColorRes.white).copyWith(
                decoration: TextDecoration.none,
              ),
            ),
            InkWell(
              onTap: onTap,
              child: Container(
                height: 37,
                width: 37,
                decoration: BoxDecoration(
                    color: ColorRes.white.withValues(alpha: 0.10), shape: BoxShape.circle),
                child: const Icon(
                  Icons.filter_list,
                  color: ColorRes.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
