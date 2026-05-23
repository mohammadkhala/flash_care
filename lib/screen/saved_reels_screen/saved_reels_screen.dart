import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/common/top_bar_area.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/reels/reels.dart';
import 'package:patient_flutter/screen/doctor_profile_screen/widget/reel_page.dart';
import 'package:patient_flutter/screen/saved_reels_screen/saved_reels_screen_controller.dart';

class SavedReelsScreen extends StatelessWidget {
  const SavedReelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SavedReelsScreenController());
    return Scaffold(
      body: Column(
        children: [
          TopBarArea(title: S.of(context).savedReels),
          const SizedBox(height: 10),
          Expanded(
            child: Obx(
              () {
                return controller.isLoading.value && controller.reels.isEmpty
                    ? CustomUi.loaderWidget()
                    : controller.reels.isEmpty
                        ? CustomUi.noDataImage(message: S.of(context).noReels)
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
                                onReelScreenBack:
                                    controller.onRemoveUnsavedReel,
                              );
                            },
                          );
              },
            ),
          )
        ],
      ),
    );
  }
}
