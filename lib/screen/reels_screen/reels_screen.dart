import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/common/my_refresh_indicator.dart';
import 'package:doctor_flutter/model/reel/reels.dart';
import 'package:doctor_flutter/screen/reels_screen/reel/reel_page.dart';
import 'package:doctor_flutter/screen/reels_screen/reels_screen_controller.dart';
import 'package:doctor_flutter/utils/asset_res.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class ReelsScreen extends StatelessWidget {
  final RxList<Reel> reels;
  final int position;
  final Widget? widget;
  final Future<void> Function()? onFetchMoreData;
  final Future<void> Function()? onRefresh;
  final RxBool? isLoading;
  final bool isHomePage;

  const ReelsScreen(
      {super.key,
      required this.reels,
      required this.position,
      this.onFetchMoreData,
      this.widget,
      this.isLoading,
      this.isHomePage = false,
      this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final ReelsScreenController controller = Get.put(
        ReelsScreenController(
            reels: reels,
            position: position.obs,
            onFetchMoreData: onFetchMoreData,
            onRefresh: onRefresh,
            isHomePage: isHomePage),
        tag: isHomePage
            ? ReelsScreenController.tag
            : '${DateTime.now().millisecondsSinceEpoch}');

    return Scaffold(
      backgroundColor: ColorRes.black,
      body: Stack(
        children: [
          MyRefreshIndicator(
            onRefresh: onRefresh ?? () async {},
            shouldRefresh: onRefresh != null,
            child: Obx(() {
              final reels = controller.reels;
              bool isLoading = this.isLoading?.value ?? false;
              return isLoading && reels.isEmpty
                  ? CustomUi.loaderWidget()
                  : !isLoading && reels.isEmpty
                      ? CustomUi.noData()
                      : PageView.builder(
                          controller: controller.pageController,
                          itemCount: reels.length,
                          physics: const CustomPageViewScrollPhysics(),
                          onPageChanged: controller.onPageChanged,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, index) {
                            final reel = reels[index];
                            return Obx(() {
                              VideoPlayerController? videoController =
                                  controller.videoControllers[index];
                              return ReelPage(
                                  reelData: reel,
                                  videoPlayerController: videoController,
                                  likeKey: GlobalKey());
                            });
                          },
                        );
            }),
          ),
          SafeArea(
            bottom: false,
            child: Container(
              height: 30,
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 10,
                children: [
                  Visibility(
                      visible: !isHomePage,
                      replacement: SizedBox(height: 30, width: 30),
                      child: Image.asset(AssetRes.icBackArrow,
                          height: 30, width: 30)),
                  if (widget != null) Expanded(child: widget!),
                  InkWell(
                      onTap: controller.onReportTap,
                      child: Image.asset(AssetRes.icReport,
                          width: 30, height: 30)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({super.parent});

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor)!);
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 1,
        stiffness: 600,
        damping: 60,
      );
}
