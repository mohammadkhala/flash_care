import 'dart:io';
import 'dart:ui';

import 'package:doctor_flutter/common/text_button_custom.dart';
import 'package:doctor_flutter/common/top_bar_area.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/screen/upload_reel_screen/upload_reel_screen_controller.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UploadReelScreen extends StatelessWidget {
  final String videoUrl;
  final String thumbnail;
  final DoctorData? doctorData;

  const UploadReelScreen(
      {super.key,
      required this.videoUrl,
      required this.thumbnail,
      this.doctorData});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
        UploadReelScreenController(videoUrl.obs, thumbnail.obs, doctorData));
    return Scaffold(
      body: Column(
        children: [
          TopBarArea(title: S.of(context).uploadReel),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 240,
                  width: Get.width / 2.6,
                  margin: const EdgeInsets.symmetric(vertical: 15),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: SmoothBorderRadius(
                            cornerRadius: 10, cornerSmoothing: 1),
                        child: Obx(
                          () => Image.file(File(controller.thumbnail.value),
                              height: 240,
                              width: Get.width / 2.6,
                              fit: BoxFit.cover),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            BuildCustomContainer(
                                onTap: controller.onPreviewTap,
                                title: S.of(context).preview),
                            BuildCustomContainer(
                                onTap: controller.onChangeCover,
                                title: S.of(context).changeCover),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  height: 120,
                  color: ColorRes.whiteSmoke,
                  child: TextField(
                      controller: controller.captionController.value,
                      onChanged: controller.onChangedText,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        hintText: '${S.of(context).enterCaptionHere}..',
                        hintStyle: const TextStyle(
                            fontFamily: FontRes.medium,
                            fontSize: 16,
                            color: ColorRes.silverChalice),
                          counter: const SizedBox()),
                      maxLength: 400,
                      style: const TextStyle(
                          color: ColorRes.silverChalice,
                          fontSize: 16,
                          fontFamily: FontRes.regular),
                      onTapOutside: (event) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      expands: true,
                      maxLines: null,
                      minLines: null),
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Padding(
                    padding: const EdgeInsets.all(7.0),
                    child: Obx(
                      () => Text(
                        '${controller.counterText}/400',
                        style: const TextStyle(
                          fontFamily: FontRes.regular,
                          fontSize: 18,
                          color: ColorRes.davyGrey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
          Container(
            color: ColorRes.havelockBlue,
            child: TextButtonCustom(
              onPressed: controller.onUploadReel,
              title: S.of(context).publish,
              titleColor: ColorRes.white,
              backgroundColor: ColorRes.havelockBlue,
            ),
          )
        ],
      ),
    );
  }
}

class BuildCustomContainer extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const BuildCustomContainer(
      {super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: SmoothBorderRadius(cornerRadius: 20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
                borderRadius: SmoothBorderRadius(cornerRadius: 20),
                border: Border.all(color: ColorRes.white.withValues(alpha: .2))),
            child: Text(
              title,
              style: const TextStyle(
                  fontFamily: FontRes.regular,
                  fontSize: 13,
                  color: ColorRes.white),
            ),
          ),
        ),
      ),
    );
  }
}
