import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/common/top_bar_area.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/reel/reels.dart';
import 'package:doctor_flutter/screen/profile_screen/widget/reel_page.dart';
import 'package:doctor_flutter/screen/saved_reels_screen/saved_reels_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SavedReelsScreen extends StatelessWidget {
  const SavedReelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SavedReelsScreenController());
    return Scaffold(
      body: Column(
        children: [
          TopBarArea(title: S.of(context).savedReels),
          Expanded(
              child: Obx(
            () => controller.isLoading.value && controller.reels.isEmpty
                ? CustomUi.loaderWidget()
                : controller.reels.isEmpty
                    ? CustomUi.noDataImage(message: S.of(context).noSavedReels)
                    : GridView.builder(
                        primary: false,
                        shrinkWrap: true,
                        itemCount: controller.reels.length,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
          ))
        ],
      ),
    );
  }
}
