import 'package:doctor_flutter/common/confirmation_dialog.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/model/message/api_status.dart';
import 'package:doctor_flutter/model/reel/reels.dart';
import 'package:doctor_flutter/model/review/review.dart';
import 'package:doctor_flutter/screen/service_location_screen/service_location_screen.dart';
import 'package:doctor_flutter/screen/services_screen/services_screen.dart';
import 'package:doctor_flutter/screen/setting_screen/setting_screen.dart';
import 'package:doctor_flutter/screen/upload_reel_screen/upload_reel_screen.dart';
import 'package:doctor_flutter/service/api_service.dart';
import 'package:doctor_flutter/service/session_manager.dart';
import 'package:doctor_flutter/utils/const_res.dart';
import 'package:doctor_flutter/utils/urls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';

class ProfileScreenController extends GetxController {
  RxList<String> list = [
    S.current.details,
    S.current.reels,
    S.current.experience,
    S.current.education,
    S.current.reviews,
    S.current.awards
  ].obs;

  Rx<DoctorData?> doctorData;

  ProfileScreenController(this.doctorData);

  RxInt selectedCategory = 0.obs;

  bool isShowMore = false;
  bool isPosition = false;
  RxBool isReviewLoading = false.obs;
  RxBool isReelLoading = false.obs;
  RxBool isLoading = false.obs;

  ScrollController scrollController = ScrollController();
  ScrollController reviewScrollController = ScrollController();
  ImagePicker picker = ImagePicker();

  RxDouble opacity = 1.0.obs;
  double maxExtent = 300.0;
  double currentExtent = 300.0;
  bool hasNoMoreReel = false;
  bool hasNoMoreReview = false;

  RxList<ReviewData> reviewData = <ReviewData>[].obs;
  RxList<Reel> reels = <Reel>[].obs;

  @override
  void onInit() {
    super.onInit();
    initApiCalling();
  }

  initApiCalling() async {
    await doctorProfileApiCall();
    fetchDoctorReview();
    fetchDoctorReels();
    scrollListener();
  }

  Future<void> doctorProfileApiCall() async {
    if (doctorData.value == null) {
      isLoading.value = true;
    }
    Registration data = await ApiService.instance.fetchMyDoctorProfile(
        doctorId:
            doctorData.value?.id ?? SessionManager.instance.getDoctorId());
    if (data.status == true) {
      doctorData.value = data.data;
    }
    isLoading.value = false;
  }

  void scrollListener() {
    scrollController.addListener(() {
      currentExtent = maxExtent - scrollController.offset;
      if (currentExtent < 0) currentExtent = 0.0;
      if (currentExtent > maxExtent) currentExtent = maxExtent;
      var temp = (currentExtent * 0.233333);
      var size = temp < 35.0 ? 35.0 : temp;
      var o = (-1 * (size - 70)) * 0.02857143;
      opacity.value = 1 - (o > 1.0 ? 1.0 : o);

      if (scrollController.offset > 270) {
        isPosition = true;
      } else {
        isPosition = false;
      }

      if (selectedCategory.value == 1) {
        loadMoreReel();
      }
      if (selectedCategory.value == 4) {
        _loadMoreReview();
      }
    });
  }

  void onShowMoreTap() {
    isShowMore = !isShowMore;
    update();
  }

  void onCategoryChange(int category) {
    selectedCategory.value = category;
    update();
  }

  void navigateServiceScreen({required int type}) {
    Get.to(() => ServicesScreen(type: type))?.then((value) {
      doctorProfileApiCall();
    });
  }

  void navigateServiceLocationScreen() {
    Get.to(() => const ServiceLocationScreen())?.then((value) {
      doctorProfileApiCall();
    });
  }

  void fetchDoctorReview() {
    if (hasNoMoreReview) return;
    isReviewLoading.value = true;
    ApiService.instance
        .fetchDoctorReviews(start: reviewData.length)
        .then((value) {
      if (value.status == true) {
        reviewData.addAll(value.data ?? []);
      }
      if ((value.data?.length ?? 0) < paginationLimit) {
        hasNoMoreReview = true;
      }
      isReviewLoading.value = false;
      update();
    });
  }

  void onSettingTap() {
    Get.to(() => SettingScreen(doctorData: doctorData.value))?.then((value) {
      doctorProfileApiCall();
    });
  }

  void onAddReel() {
    picker
        .pickVideo(
            source: ImageSource.gallery,
            maxDuration: const Duration(seconds: 60))
        .then((value) async {
      if (value != null) {
        await VideoCompress.getFileThumbnail(value.path).then((value) {
          Get.to<Reel>(() => UploadReelScreen(
              thumbnail: value.path,
              videoUrl: value.path,
              doctorData: doctorData.value))?.then((value) {
            if (value != null) {
              reels.insert(0, value);
            }
          });
        });
      }
    });
  }

  void fetchDoctorReels() {
    if (hasNoMoreReel) return;
    isReelLoading.value = true;
    ApiService.instance.call(
        url: Urls.fetchMyReelsDoctorApp,
        completion: (response) {
          Reels data = Reels.fromJson(response);
          if (data.status == true) {
            reels.addAll(data.data ?? []);
          }
          if ((data.data?.length ?? 0) < paginationLimit) {
            hasNoMoreReel = true;
          }
          isReelLoading.value = false;
        },
        param: {
          pDoctorId: SessionManager.instance.getDoctorId(),
          pStart: reels.length,
          pCount: paginationLimit
        });
  }

  void loadMoreReel() {
    if (scrollController.hasClients &&
        scrollController.offset == scrollController.position.maxScrollExtent &&
        !isReelLoading.value) {
      fetchDoctorReels();
    }
  }

  void _loadMoreReview() {
    if (scrollController.hasClients &&
        scrollController.offset == scrollController.position.maxScrollExtent &&
        !isReviewLoading.value) {
      fetchDoctorReview();
    }
  }

  onDeleteReel(Reel reel) {
    Get.dialog(ConfirmationDialog(
      aspectRatio: 1.6,
      onPositiveTap: () {
        ApiService.instance.call(
          url: Urls.deleteReel,
          param: {pReelId: reel.id, pDoctorId: reel.doctorId},
          completion: (response) {
            ApiStatus data = ApiStatus.fromJson(response);
            if (data.status == true) {
              reels.removeWhere(
                  (element) => element.id?.toInt() == reel.id?.toInt());
            }
          },
        );
      },
      title1: S.current.deletePostPermanently,
      title2: S.current.areYouSureYouWantToDeleteThisPostThis,
      positiveText: S.current.delete,
    ));
  }
}
