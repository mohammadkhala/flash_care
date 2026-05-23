import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/common/image_builder_custom.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/reel/reels.dart';
import 'package:doctor_flutter/screen/profile_screen/profile_screen_controller.dart';
import 'package:doctor_flutter/screen/reels_screen/reels_screen.dart';
import 'package:doctor_flutter/service/session_manager.dart';
import 'package:doctor_flutter/utils/asset_res.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/extention.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReelPage extends StatelessWidget {
  final ProfileScreenController controller;

  const ReelPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.isReelLoading.value && controller.reels.isEmpty
          ? CustomUi.loaderWidget()
          : controller.reels.isEmpty
              ? CustomUi.noDataImage(message: S.current.noReels)
              : GridView.builder(
                  primary: false,
                  shrinkWrap: true,
                  itemCount: controller.reels.length,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      mainAxisExtent: 180),
                  itemBuilder: (context, index) {
                    Reel reel = controller.reels[index];
                    return ReelCard(
                      reels: controller.reels,
                      index: index,
                      reel: reel,
                      onDeleteReel: controller.onDeleteReel,
                    );
                  },
                ),
    );
  }
}

class ReelCard extends StatelessWidget {
  final List<Reel> reels;
  final int index;
  final Function(Reel reel)? onDeleteReel;
  final Reel reel;

  const ReelCard(
      {super.key,
      required this.reels,
      required this.index,
      this.onDeleteReel,
      required this.reel});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: () {
            Get.to(() => ReelsScreen(reels: reels.obs, position: index));
          },
          child: ClipRRect(
              borderRadius: SmoothBorderRadius(cornerRadius: 10),
              child: Stack(
                children: [
                  ImageBuilderCustom(reel.thumb,
                      name: reel.doctor?.name, radius: 10, size: Get.height),
                  Align(
                    alignment: AlignmentDirectional.bottomEnd,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(color: ColorRes.white.withValues(alpha: .2), blurRadius: 10)
                            ]),
                            child: Image.asset(
                              AssetRes.icPlay,
                              height: 15,
                              width: 15,
                              color: ColorRes.white,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            (reel.views ?? 0).formatCurrency,
                            style: const TextStyle(
                              color: ColorRes.white,
                              fontFamily: FontRes.medium,
                              fontSize: 12,
                              shadows: [
                                Shadow(color: ColorRes.white, blurRadius: 10)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              )),
        ),
        if (reel.doctorId == SessionManager.instance.getDoctorId())
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: InkWell(
              onTap: onDeleteReel != null ? () => onDeleteReel!(reel) : () {},
              child: Container(
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(color: ColorRes.white.withValues(alpha: .2), blurRadius: 10)
                ]),
                child: Image.asset(
                  AssetRes.icDelete,
                  height: 25,
                  width: 25,
                  color: ColorRes.white,
                ),
              ),
            ),
          )
      ],
    );
  }
}
