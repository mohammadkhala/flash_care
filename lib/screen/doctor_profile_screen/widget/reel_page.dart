import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/common/image_builder_custom.dart';
import 'package:patient_flutter/model/reels/reels.dart';
import 'package:patient_flutter/screen/doctor_profile_screen/doctor_profile_screen_controller.dart';
import 'package:patient_flutter/screen/reels_screen/reels_screen.dart';
import 'package:patient_flutter/utils/asset_res.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/extention.dart';
import 'package:patient_flutter/utils/font_res.dart';

class ReelPage extends StatelessWidget {
  final DoctorProfileScreenController controller;

  const ReelPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return controller.isReelLoading.value && controller.reels.isEmpty
            ? CustomUi.loaderWidget()
            : GridView.builder(
                primary: false,
                shrinkWrap: true,
                itemCount: controller.reels.length,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    mainAxisExtent: 190),
                itemBuilder: (context, index) {
                  Reel reel = controller.reels[index];
                  return ReelCard(
                    reels: controller.reels,
                    index: index,
                    reel: reel,
                  );
                },
              );
      },
    );
  }
}

class ReelCard extends StatelessWidget {
  final List<Reel> reels;
  final int index;
  final Reel reel;
  final VoidCallback? onReelScreenBack;

  const ReelCard(
      {super.key,
      required this.reels,
      required this.index,
      required this.reel,
      this.onReelScreenBack});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(() => ReelsScreen(reels: reels.obs, position: index))?.then(
          (value) {
            onReelScreenBack?.call();
          },
        );
      },
      child: ClipRRect(
          borderRadius: SmoothBorderRadius(cornerRadius: 10),
          child: Stack(
            children: [
              ImageBuilderCustom(reel.thumb,
                  size: Get.height,
                  radius: 10,
                  bgColor: ColorRes.whiteSmoke,
                  name: reel.doctor?.name),
              Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                              color: ColorRes.white.withValues(alpha: .2),
                              blurRadius: 10)
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
    );
  }
}
