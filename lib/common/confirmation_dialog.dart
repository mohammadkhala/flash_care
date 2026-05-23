import 'dart:ui';

import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title1,
    required this.title2,
    required this.onPositiveTap,
    required this.aspectRatio,
    this.positiveText,
  });

  final String title1;
  final String title2;
  final VoidCallback onPositiveTap;
  final double aspectRatio;
  final String? positiveText;

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: AspectRatio(
          aspectRatio: aspectRatio > 0 ? aspectRatio : 1.5,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: ShapeDecoration(
                color: ColorRes.white,
                shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1))),
            child: Column(
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    title1,
                    style: MyTextStyle.montserratBold(size: 17, color: ColorRes.charcoalGrey),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    title2,
                    style: MyTextStyle.montserratRegular(size: 14, color: ColorRes.battleshipGrey),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.grey[300]!, width: 0.5),
                              right: isRTL
                                  ? BorderSide.none
                                  : BorderSide(color: Colors.grey[300]!, width: 0.5),
                            ),
                          ),
                          child: Text(
                            S.of(context).cancel,
                            style: MyTextStyle.montserratMedium(
                                size: 17, color: ColorRes.battleshipGrey),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Get.back();
                          onPositiveTap();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.grey[300]!, width: 0.5),
                              right: isRTL
                                  ? BorderSide(color: Colors.grey[300]!, width: 0.5)
                                  : BorderSide.none,
                            ),
                          ),
                          child: Text(
                            positiveText ?? S.of(context).yes,
                            style: MyTextStyle.montserratSemiBold(
                              size: 17,
                              color: ColorRes.bittersweet,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
