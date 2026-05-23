import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/model/message/message.dart';
import 'package:patient_flutter/model/reels/add_comment.dart';
import 'package:patient_flutter/model/reels/fetch_comment.dart';
import 'package:patient_flutter/model/reels/reels.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/screen/reels_screen/comment/comment_sheet.dart';
import 'package:patient_flutter/screen/reels_screen/reels_screen_controller.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/services/session_manager.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/urls.dart';

class ReelController extends GetxController {
  Rx<Reel> reelData;
  bool isLikeLoading = false;
  bool isSavedLoading = false;
  RxList<Comment> comments = <Comment>[].obs;
  RxBool isCommentLoading = false.obs;
  bool hasNoMoreComment = false;
  UserData? myUser;
  Timer? _debounce;

  ReelController(this.reelData);

  @override
  void onInit() {
    super.onInit();
    initPlayerForHomeReelScreen();
  }

  @override
  void onClose() {
    super.onClose();
    reelData.close();
    _debounce?.cancel();
  }

  updateReelData({required Reel reel, bool isIncreaseCoin = false}) {
    if (isIncreaseCoin) {
      reelData.update((val) => val?.increaseViews());
    } else {
      reelData.value = reel;
    }
  }

  void onLikeTap() {
    // Toggle the like state and update count
    reelData.update((reel) {
      if (reel != null) {
        final isCurrentlyLiked = reel.isLiked ?? false;
        reel.isLiked = !isCurrentlyLiked;
        reel.likesCount = (isCurrentlyLiked
            ? (reel.likesCount ?? 0).clamp(1, double.infinity).toInt() - 1
            : (reel.likesCount ?? 0) + 1);
      }
    });

    // Debounced API update
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () async {
      // If already liked or disliked, match it with the initial like status, return if it matches

      ApiService.instance.call(
        url: Urls.likeReelPatientApp,
        param: {
          pReelId: reelData.value.id,
          pUserId: SessionManager.instance.getUserID()
        },
        completion: (response) {
          final data = Message.fromJson(response);
          if (data.status == false) {
            // Revert state if the API call fails
            reelData.update((reel) {
              if (reel != null) {
                final isCurrentlyLiked = reel.isLiked ?? false;
                reel.isLiked = !isCurrentlyLiked;
                reel.likesCount = isCurrentlyLiked
                    ? (reel.likesCount ?? 0).clamp(1, double.infinity).toInt() -
                        1
                    : (reel.likesCount ?? 0) + 1;
              }
            });
          }
        },
      );
    });
  }

  void onCommentTap() {
    fetchComment();
    Get.bottomSheet(Obx(() => CommentSheet(reelData: reelData.value)),
        isScrollControlled: true);
  }

  onSendComment(String comment) {
    FocusManager.instance.primaryFocus?.unfocus();
    CustomUi.loader();
    ApiService.instance.call(
        url: Urls.addCommentOnReelPatientApp,
        param: {
          pUserId: SessionManager.instance.getUserID(),
          pReelId: reelData.value.id,
          pComment: comment
        },
        completion: (response) {
          Get.back();
          AddComment data = AddComment.fromJson(response);
          if (data.status == true) {
            if (data.data != null) {
              comments.insert(0, data.data!);
              reelData.update(
                (val) {
                  if (val != null) {
                    val.increaseCommentCount(1);
                  }
                },
              );
            }
          }
        });
  }

  void fetchComment() {
    if (hasNoMoreComment) return;
    isCommentLoading.value = true;
    ApiService.instance.call(
        url: Urls.fetchReelComments,
        param: {
          pReelId: reelData.value.id,
          pStart: comments.length,
          pCount: paginationLimit
        },
        completion: (response) {
          FetchComment data = FetchComment.fromJson(response);
          if (data.status == true) {
            comments.addAll(data.data ?? []);
          }
          if ((data.data?.length ?? 0) < paginationLimit) {
            hasNoMoreComment = true;
          }
          reelData.update((val) {
            if (val != null) {
              val.commentsCount = comments.length;
            }
          });
          isCommentLoading.value = false;
        });
  }

  void initPlayerForHomeReelScreen() {
    if (Get.isRegistered<ReelsScreenController>(
        tag: ReelsScreenController.tag)) {
      var controller =
          Get.find<ReelsScreenController>(tag: ReelsScreenController.tag);
      Future.delayed(Duration(milliseconds: 500), () {
        if (controller.videoControllers.isEmpty) {
          controller.initVideoPlayer();
        }
      });
    }
  }

  void onBookmarkTap() async {
    bool isSaved = reelData.value.isSaved;

    try {
      if (isSaved) {
        isSaved = false;
      } else {
        isSaved = true;
      }
      reelData.update((val) => val?.isSaved = isSaved);

      // Debounced API update
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 1000), () async {
        List<String> savedList =
            (SessionManager.instance.getUser()?.savedReels ?? '')
                .split(',')
                .toList();
        // Make a single API call after updating the list
        Registration registration = await ApiService()
            .updateUserDetails(savedReels: savedList.join(','));
        if (registration.status == false) {
          reelData.update((val) => val?.isSaved = isSaved);
        }
        debugPrint('Updated saved list sent to API: ${savedList.join(',')}');
      });
    } catch (e) {
      debugPrint('Error in onBookmarkTap: $e');
    }
  }
}
