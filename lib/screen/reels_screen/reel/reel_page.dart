import 'package:detectable_text_field/detectable_text_field.dart';
import 'package:doctor_flutter/common/black_gradient_shadow.dart';
import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/common/image_builder_custom.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/reel/reels.dart';
import 'package:doctor_flutter/screen/reels_screen/reel/reel_page_controller.dart';
import 'package:doctor_flutter/utils/asset_res.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/extention.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ReelPage extends StatelessWidget {
  final Reel reelData;
  final VideoPlayerController? videoPlayerController;
  final GlobalKey likeKey;

  const ReelPage(
      {super.key,
      required this.reelData,
      this.videoPlayerController,
      required this.likeKey});

  @override
  Widget build(BuildContext context) {
    ReelController controller;
    if (Get.isRegistered<ReelController>(tag: '${reelData.id}')) {
      controller = Get.find<ReelController>(tag: '${reelData.id}');
      // Delay update until after current frame to ensure proper UI update without conflicts
    } else {
      controller = Get.put(ReelController(reelData.obs), tag: '${reelData.id}');
    }

    Widget buildVideoContent() {
      final size = videoPlayerController?.value.size;

      bool hasVideoInitialize = videoPlayerController != null;

      return hasVideoInitialize
          ? ClipRRect(
              child: SizedBox.expand(
                child: FittedBox(
                  fit: (size?.width ?? 0) < (size?.height ?? 0)
                      ? BoxFit.cover
                      : BoxFit.fitWidth,
                  child: SizedBox(
                      width: size?.width ?? 0,
                      height: size?.height ?? 0,
                      child: VideoPlayer(videoPlayerController!)),
                ),
              ),
            )
          : CustomUi.loaderWidget();
    }

    Widget buildPlayPauseOverlay(VideoPlayerController? controller) {
      return ValueListenableBuilder(
        valueListenable: controller!,
        builder: (context, value, child) {
          return !value.isInitialized || value.isBuffering
              ? const Center(
                  child: CupertinoActivityIndicator(
                      radius: 12, color: Colors.white))
              : AnimatedOpacity(
                  duration: const Duration(milliseconds: 10),
                  opacity: value.isPlaying ? 0.0 : 1.0,
                  child: Align(
                    alignment: Alignment.center,
                    child: ClipRRect(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 30,
                        cornerSmoothing: 1,
                      ),
                      child: Image.asset(
                          value.isPlaying ? AssetRes.icPause : AssetRes.icPlay,
                          width: 30,
                          height: 30,
                          color: ColorRes.white),
                    ),
                  ),
                );
        },
      );
    }

    void togglePlayPause() {
      final controllerValue = videoPlayerController?.value;
      if (controllerValue == null) {
        return;
      }

      if (controllerValue.isPlaying) {
        videoPlayerController?.pause();
      } else {
        videoPlayerController?.play();
      }
    }

    void handleVisibilityChanged(VisibilityInfo info) {
      final controllerValue = videoPlayerController?.value;
      if (controllerValue == null) {
        return;
      }

      if ((info.visibleFraction * 100) > 90) {
        videoPlayerController?.play();
      } else {
        videoPlayerController?.pause();
      }
    }

    return Scaffold(
      backgroundColor: ColorRes.black,
      resizeToAvoidBottomInset: false,
      body: VisibilityDetector(
        key: Key('ke1${reelData.video ?? ''}'),
        onVisibilityChanged: handleVisibilityChanged,
        child: InkWell(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            togglePlayPause();
          },
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              buildVideoContent(),
              const BlackGradientShadow(),
              ReelInfoSection(
                  controller: controller,
                  likeKey: likeKey,
                  videoPlayerPlusController: videoPlayerController),
              if (videoPlayerController != null)
                buildPlayPauseOverlay(videoPlayerController),
            ],
          ),
        ),
      ),
    );
  }
}

class ReelInfoSection extends StatelessWidget {
  final ReelController controller;
  final GlobalKey likeKey;
  final VideoPlayerController? videoPlayerPlusController;

  const ReelInfoSection(
      {super.key,
      required this.controller,
      required this.likeKey,
      required this.videoPlayerPlusController});

  @override
  Widget build(BuildContext context) {
    return ReelInfoRow(controller: controller, likeKey: likeKey);
  }
}

class ReelInfoRow extends StatelessWidget {
  final ReelController controller;
  final GlobalKey likeKey;

  const ReelInfoRow(
      {super.key, required this.controller, required this.likeKey});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Obx(() {
            return UserInformation(reelData: controller.reelData.value);
          }),
        ),
        SideBarList(reelData: controller.reelData.value),
      ],
    );
  }
}

class UserInformation extends StatelessWidget {
  final Reel reelData;

  const UserInformation({super.key, required this.reelData});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(onTap: () {}, child: UserInfoHeader(reel: reelData)),
            UserDescription(reel: reelData),
            UserStats(reel: reelData),
          ],
        ),
      ),
    );
  }
}

class UserInfoHeader extends StatelessWidget {
  final Reel reel;

  const UserInfoHeader({required this.reel, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ImageBuilderCustom(reel.doctor?.image,
                size: 45, name: reel.doctor?.name),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reel.doctor?.name ?? '',
                      style: const TextStyle(
                          color: ColorRes.white,
                          fontFamily: FontRes.extraBold,
                          fontSize: 17),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(reel.doctor?.designation ?? '',
                      style: const TextStyle(
                          color: ColorRes.white,
                          fontFamily: FontRes.light,
                          fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class UserDescription extends StatelessWidget {
  final Reel reel;

  const UserDescription({super.key, required this.reel});

  @override
  Widget build(BuildContext context) {
    return (reel.description ?? '').isNotEmpty
        ? Column(
            children: [
              ConstrainedBox(
                constraints:
                    BoxConstraints(maxHeight: 150, maxWidth: Get.width - 70),
                child: SingleChildScrollView(
                  child: DetectableText(
                      text: reel.description ?? '',
                      detectionRegExp: RegExp(r"\B#\w\w+"),
                      basicStyle: TextStyle(
                          color: ColorRes.white.withValues(alpha: .8),
                          fontSize: 14),
                      trimMode: TrimMode.Line,
                      trimLines: 3,
                      trimCollapsedText: ' more',
                      trimExpandedText: '   less',
                      moreStyle: TextStyle(
                          color: ColorRes.white.withValues(alpha: .8),
                          fontSize: 14,
                          fontFamily: FontRes.semiBold),
                      lessStyle: TextStyle(
                          color: ColorRes.white.withValues(alpha: .8),
                          fontSize: 14,
                          fontFamily: FontRes.semiBold)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          )
        : const SizedBox();
  }
}

class UserStats extends StatelessWidget {
  final Reel reel;

  const UserStats({super.key, required this.reel});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReelController>(tag: '${reel.id}');
    return Row(
      children: [
        Text(
          (reel.createdAt ?? '').reelDateFormat,
          style: const TextStyle(
              color: ColorRes.white, fontSize: 12, fontFamily: FontRes.light),
        ),
        if ((reel.views ?? 0) > 0)
          Container(
            height: 10,
            width: .5,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: const BoxDecoration(color: ColorRes.white),
          ),
        Obx(
          () => (controller.reelData.value.views ?? 0) > 0
              ? Text(
                  '${(controller.reelData.value.views ?? 0).formatCurrency} ${S.of(context).views}',
                  style: const TextStyle(
                      color: ColorRes.white,
                      fontSize: 12,
                      fontFamily: FontRes.light),
                )
              : const SizedBox(),
        ),
      ],
    );
  }
}

class SideBarList extends StatelessWidget {
  final Reel reelData;

  const SideBarList({super.key, required this.reelData});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReelController>(tag: '${reelData.id}');
    return Obx(() {
      Reel reel = controller.reelData.value;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconWithLabel(
                onTap: controller.onLikeTap,
                image: reel.isLiked ?? false
                    ? AssetRes.icFillHeart
                    : AssetRes.icHeart,
                text: (reel.likesCount ?? 0).formatCurrency),
            IconWithLabel(
                onTap: controller.onCommentTap,
                image: AssetRes.icComment,
                text: (reel.commentsCount ?? 0).formatCurrency),
            IconWithLabel(
                onTap: controller.onBookmarkTap,
                image: reel.isSaved
                    ? AssetRes.icFillBookmark
                    : AssetRes.icBookmark,
                text: ''),
            const SizedBox(height: 50),
          ],
        ),
      );
    });
  }
}

class IconWithLabel extends StatelessWidget {
  final VoidCallback onTap;
  final String image;
  final String text;

  const IconWithLabel({
    super.key,
    required this.onTap,
    required this.image,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.5),
      child: Column(
        children: [
          InkWell(
              onTap: onTap, child: Image.asset(image, width: 34, height: 34)),
          if (text.isNotEmpty)
            Text(
              text,
              style: const TextStyle(
                fontFamily: FontRes.medium,
                fontSize: 13,
                color: ColorRes.white,
                shadows: <Shadow>[
                  Shadow(
                      offset: Offset(0.0, 1.0),
                      blurRadius: 3.0,
                      color: ColorRes.smokeyGrey)
                ],
              ),
            ),
        ],
      ),
    );
  }
}
