import 'dart:io';

import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/model/reel/add_reel.dart';
import 'package:doctor_flutter/model/reel/reels.dart';
import 'package:doctor_flutter/screen/upload_reel_screen/widget/preview_reel.dart';
import 'package:doctor_flutter/service/api_service.dart';
import 'package:doctor_flutter/service/session_manager.dart';
import 'package:doctor_flutter/utils/const_res.dart';
import 'package:doctor_flutter/utils/urls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class UploadReelScreenController extends GetxController {
  RxString videoUrl;
  RxString thumbnail;
  DoctorData? doctorData;
  ImagePicker picker = ImagePicker();
  Rx<TextEditingController> captionController = TextEditingController().obs;
  RxInt counterText = 0.obs;
  late VideoPlayerController videoPlayerController;

  UploadReelScreenController(this.videoUrl, this.thumbnail, this.doctorData);

  @override
  void onInit() {
    super.onInit();
    initVideo();
  }

  void initVideo() {
    videoPlayerController = VideoPlayerController.file(File(videoUrl.value))
      ..initialize();
  }

  void onChangeCover() async {
    XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        imageQuality: imageQuality,
        maxHeight: maxHeight);
    if (file != null) {
      thumbnail.value = file.path;
    }
  }

  void onChangedText(String value) {
    counterText.value = value.length;
  }

  void onUploadReel() {
    CustomUi.loader();
    ApiService.instance.multiPartCallApi(
      url: Urls.uploadReelByDoctor,
      filesMap: {
        pVideo: [XFile(videoUrl.value)],
        pThumb: [XFile(thumbnail.value)],
      },
      completion: (response) {
        AddReel status = AddReel.fromJson(response);
        Get.back();
        if (status.status == true) {
          Get.back(result: status.data);
          CustomUi.snackBar(message: status.message);
        } else {
          CustomUi.snackBar(message: status.message);
        }
      },
      param: {
        pDoctorId: SessionManager.instance.getDoctorId(),
        pDescription: captionController.value.text.trim()
      },
    );
  }

  void onPreviewTap() {
    Reel reel = Reel(
      thumb: thumbnail.value,
      video: videoUrl.value,
      description: captionController.value.text.trim(),
      isLiked: false,
      commentsCount: 1,
      views: 1,
      likesCount: 1,
      doctor: doctorData,
        createdAt: DateTime.now().toIso8601String());
    videoPlayerController.play();
    videoPlayerController.setLooping(true);
    Get.bottomSheet(
            PreviewReel(
                videoPlayerController: videoPlayerController, reel: reel),
            isScrollControlled: true)
        .then(
      (value) {
        videoPlayerController.pause();
      },
    );
  }

  @override
  void onClose() {
    videoPlayerController.dispose();
    super.onClose();
  }
}
