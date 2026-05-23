import 'package:doctor_flutter/model/reel/reels.dart';
import 'package:doctor_flutter/screen/reels_screen/reel/reel_page.dart';
import 'package:doctor_flutter/screen/reels_screen/reel/reel_page_controller.dart';
import 'package:doctor_flutter/utils/asset_res.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class PreviewReel extends StatelessWidget {
  final VideoPlayerController videoPlayerController;
  final Reel reel;

  const PreviewReel({super.key, required this.videoPlayerController, required this.reel});

  @override
  Widget build(BuildContext context) {
    Get.put(ReelController(reel.obs), tag: '${reel.id}');
    return Container(
      color: ColorRes.black,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          if (videoPlayerController.value.isInitialized)
            Align(
              alignment: Alignment.center,
              child: SizedBox.expand(
                child: FittedBox(
                  fit: videoPlayerController.value.size.width <
                          videoPlayerController.value.size.height
                      ? BoxFit.cover
                      : BoxFit.fitWidth,
                  child: SizedBox(
                      width: videoPlayerController.value.size.width,
                      height: videoPlayerController.value.size.height,
                      child: VideoPlayer(videoPlayerController)),
                ),
              ),
            ),
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Image.asset(AssetRes.icBlackShadow_1, width: double.infinity, fit: BoxFit.fitWidth),
              Align(
                  alignment: AlignmentDirectional.bottomStart,
                  child: UserInformation(reelData: reel)),
              Align(
                  alignment: AlignmentDirectional.bottomEnd,
                  child: SideBarList(reelData: reel)),
              Positioned(
                top: AppBar().preferredSize.height,
                left: 20,
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: InkWell(
                    onTap: () => Get.back(),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: ColorRes.white,
                      size: 20,
                      shadows: [Shadow(color: ColorRes.grey, blurRadius: 5)],
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
