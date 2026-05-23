import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/model/message/message.dart';
import 'package:patient_flutter/model/reels/reels.dart';
import 'package:patient_flutter/screen/dashboard_screen/dashboard_screen_controller.dart';
import 'package:patient_flutter/screen/home_reel_screen/home_reel_screen_controller.dart';
import 'package:patient_flutter/screen/reels_screen/reel/reel_page_controller.dart';
import 'package:patient_flutter/screen/reels_screen/widget/report_sheet.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/services/video_cache_helper/video_cache_helper.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/urls.dart';
import 'package:video_player/video_player.dart';

class ReelsScreenController extends GetxController {
  static const tag = 'REEL';
  RxBool isVideoDisposing = false.obs;

  DashboardScreenController dashboardController =
      Get.find<DashboardScreenController>();

  HomeReelScreenController homeScreenController =
      Get.find<HomeReelScreenController>();
  final RxDouble previousPosition = 0.0.obs;

  RxMap<int, VideoPlayerController> videoControllers =
      <int, VideoPlayerController>{}.obs;

  RxList<Reel> reels = <Reel>[].obs;
  RxInt position = 0.obs;
  late PageController pageController;
  Future<void> Function()? onFetchMoreData;
  Future<void> Function()? onRefresh;

  bool isHomePage;

  ReelsScreenController(
      {required this.reels,
      required this.position,
      required this.onFetchMoreData,
      required this.onRefresh,
      required this.isHomePage});

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: position.value);
    if (isHomePage) {
      _setupDashboardController();
    }
    if (!isHomePage) {
      initVideoPlayer();
    }
  }

  @override
  void onClose() {
    super.onClose();
    disposeAllController();
  }

  void _setupDashboardController() {
    dashboardController.onBottomIndexChanged = (index) {
      if (index == 3) {
        videoControllers[position.value]?.play();
      } else {
        videoControllers[position.value]?.pause();
      }
    };
  }

  Future<void> _fetchMoreData() async {
    if (position >= reels.length - 3) {
      await onFetchMoreData?.call().then((value) {
        _initializeControllerAtIndex(position.value + 1);
      });
    }
  }

  void onReportTap() {
    Get.bottomSheet(ReportSheet(id: reels[position.value].id ?? -1),
        isScrollControlled: true);
  }

  Future<void> initVideoPlayer() async {
    /// Initialize 1st video
    await _initializeControllerAtIndex(position.value);

    /// Play 1st video
    _playControllerAtIndex(position.value);

    /// Initialize 2nd vide
    if (position >= 0) {
      await _initializeControllerAtIndex(position.value - 1);
    }
    await _initializeControllerAtIndex(position.value + 1);
  }

  void _playNextReel(int index) {
    _stopControllerAtIndex(index - 1); // Ensure previous reel is stopped
    _disposeControllerAtIndex(index - 2); // Dispose the older controller
    _playControllerAtIndex(index); // Play the new reel
    _initializeControllerAtIndex(index + 1); // Preload the next reel
  }

  void _playPreviousReel(int index) {
    _stopControllerAtIndex(index + 1); // Ensure next reel is stopped
    _disposeControllerAtIndex(index + 2); // Dispose the older controller
    _playControllerAtIndex(index); // Play the previous reel
    _initializeControllerAtIndex(index - 1); // Preload the previous reel
  }

  Future _initializeControllerAtIndex(int index) async {
    if (index < 0 || index >= reels.length) {
      print('🚫 Invalid index: $index, Reels Length: ${reels.length}');
      return;
    }

    // Skip if already initialized
    if (videoControllers[index] != null &&
        videoControllers[index]!.value.isInitialized) {
      return;
    }

    try {
      final VideoPlayerController controller;
      if (reels.first.id == -1) {
        controller = VideoPlayerController.file(File(reels.first.video ?? ''));
      } else {
        final rawVideo = reels[index].video ?? '';
        if (rawVideo.isEmpty) {
          print('⚠️ Video URL empty at index $index — skipping');
          return;
        }
        final videoUrl = rawVideo.startsWith('http')
            ? rawVideo
            : "${ConstRes.itemBaseURL}$rawVideo";

        controller = await getVideoPlayerController(videoUrl);
      }

      /// Add to [controllers] list
      videoControllers[index] = controller;

      /// Initialize
      await controller.initialize();
      print('🚀🚀🚀 INITIALIZED $index');
    } catch (e) {
      print('❌ Failed to initialize video at index $index: $e');
      // Remove broken controller so it won't block playback
      videoControllers.remove(index);
    }
  }

  Future<VideoPlayerController> getVideoPlayerController(
      String videoUrl) async {
    try {
      final cached = await VideoCacheHelper.getValidCachedVideo(videoUrl);
      VideoPlayerController controller;

      if (cached != null) {
        controller = VideoPlayerController.file(cached.file);
      } else {
        controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
        // Start caching in background; don't wait to avoid delaying playback
        VideoCacheHelper.downloadAndCacheVideo(videoUrl);
      }

      return controller;
    } catch (e) {
      print('❌ Error creating controller for $videoUrl: $e');
      // Return a network controller as fallback so caller can handle the error
      return VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    }
  }

  void _playControllerAtIndex(int index, {int retryCount = 0}) async {
    if (dashboardController.currentIndex.value != 3 && isHomePage) {
      return;
    }
    if (reels.length > index && index >= 0) {
      VideoPlayerController? controller = videoControllers[index];
      if (controller != null && controller.value.isInitialized) {
        controller.play();
        controller.setLooping(true);
        videoControllers.refresh();
        _increaseViewsCount(reels[index]);
        print('🚀🚀🚀 PLAYING $index');
      } else if (retryCount < 2) {
        // Attempt to initialize, but cap retries to avoid infinite loop
        await _initializeControllerAtIndex(index);
        _playControllerAtIndex(index, retryCount: retryCount + 1);
      } else {
        print('⚠️ Could not play reel at index $index after $retryCount retries');
      }
    }
  }

  void _increaseViewsCount(Reel? post) async {
    await Future.delayed(Duration(seconds: 1));
    if (post == null || post.id == null) {
      return print('Post not found or ID is null');
    }

    final postId = post.id ?? -1;
    if (postId == -1) {
      return print('Post ID $postId not found in reels');
    }

    final reelIndex = reels.indexWhere((element) => element.id == postId);
    if (reelIndex == -1) {
      return print('Post ID $postId not found in reels');
    }

    ApiService.instance.call(
      url: Urls.increaseReelViewCount,
      param: {pReelId: postId},
      completion: (response) {
        Message data = Message.fromJson(response);
        if (data.status == true) {
          final controllerTag = postId.toString();
          if (Get.isRegistered<ReelController>(tag: controllerTag)) {
            Get.find<ReelController>(tag: controllerTag)
                .updateReelData(reel: post, isIncreaseCoin: true);
          }
        }
      },
    );
  }

  void _stopControllerAtIndex(int index) {
    if (reels.length > index && index >= 0) {
      final controller = videoControllers[index];
      if (controller != null) {
        controller.pause();
        controller.seekTo(const Duration()); // Reset position
        print('🚀🚀🚀 STOPPED $index');
      }
    }
  }

  void _disposeControllerAtIndex(int index) {
    if (reels.length > index && index >= 0) {
      final VideoPlayerController? controller = videoControllers[index];
      if (controller != null) {
        _stopControllerAtIndex(index);
        controller.dispose();
        videoControllers.remove(index);
        print('🚀🚀🚀 DISPOSED $index');
      }
    }
  }

  Future<void> disposeAllController() async {
    final controllersToDispose = videoControllers.values
        .toList(); // clone to avoid concurrent modification
    videoControllers
        .clear(); // clear early to prevent usage during async dispose

    for (var controller in controllersToDispose) {
      try {
        if (controller.value.isInitialized) {
          await controller.pause(); // Optional: pause before disposing
        }
        await controller.dispose();
      } catch (e, _) {
        print('❌ Failed to dispose controller: $e');
      }
    }
  }

  void onPageChanged(int index) {
    if (index > position.value) {
      _fetchMoreData();
      _playNextReel(index);
    } else {
      _playPreviousReel(index);
    }
    position.value = index;
  }

  Future<void> onRefreshPage(List<Reel> reels) async {
    if (reels.isEmpty) {
      return;
    }

    if (onRefresh != null) {
      position.value = 0;

      if (pageController.hasClients) {
        pageController.jumpToPage(position.value);
      }

      final rawRefreshVideo = reels[position.value].video ?? '';
      String videoUrl = rawRefreshVideo.startsWith('http')
          ? rawRefreshVideo
          : "${ConstRes.itemBaseURL}$rawRefreshVideo";

      final VideoPlayerController controller =
          await getVideoPlayerController(videoUrl);
      await controller.initialize();

      // Step 2: Dispose old controllers not needed anymore
      disposeAllController();
      videoControllers[position.value] = controller;

      /// Play 1st video
      _playControllerAtIndex(position.value);
      await _initializeControllerAtIndex(position.value + 1);
    }
  }
}
