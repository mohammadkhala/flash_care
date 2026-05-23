import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class VideoUploadDialog extends StatelessWidget {
  final VoidCallback selectAnother;

  const VideoUploadDialog({super.key, required this.selectAnother});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaY: 2, sigmaX: 2),
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 65),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: AspectRatio(
          aspectRatio: 1,
          child: Column(
            children: [
              const Spacer(flex: 2),
              RichText(
                text: TextSpan(
                  style: MyTextStyle.montserratSemiBold(size: 18),
                  children: [
                    TextSpan(
                        text: S.current.tooLarge,
                        style: MyTextStyle.montserratRegular(color: ColorRes.davyGrey, size: 14)),
                    TextSpan(
                        text: ' ${S.current.video}?',
                        style: MyTextStyle.montserratRegular(color: ColorRes.davyGrey, size: 14)),
                  ],
                ),
              ),
              const Spacer(
                flex: 2,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  S.current.thisVideoIsGreaterThan15MbEtc,
                  style: MyTextStyle.montserratSemiBold(color: ColorRes.charcoalGrey),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),
              InkWell(
                highlightColor: ColorRes.transparent,
                splashColor: ColorRes.transparent,
                onTap: selectAnother,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: MyTextStyle.linearTopGradient,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    S.current.selectAnother,
                    style: MyTextStyle.montserratSemiBold(color: ColorRes.white),
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                highlightColor: ColorRes.transparent,
                splashColor: ColorRes.transparent,
                onTap: () {
                  Get.back();
                },
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    S.current.cancel,
                    style: MyTextStyle.montserratSemiBold(color: ColorRes.charcoalGrey),
                  ),
                ),
              ),
              const Spacer(
                flex: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
