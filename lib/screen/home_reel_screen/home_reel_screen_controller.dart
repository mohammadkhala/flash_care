import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/model/home/home.dart';
import 'package:patient_flutter/model/reels/reels.dart';
import 'package:patient_flutter/screen/reels_screen/reels_screen_controller.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/services/session_manager.dart';
import 'package:patient_flutter/utils/urls.dart';

class HomeReelScreenController extends GetxController
    with GetTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> animation;
  RxList<Reel> reels = <Reel>[].obs;
  Rx<Categories> selectedCategory = (Categories(id: 0, title: 'Mix')).obs;
  RxList<Categories> doctorCategories = [Categories(id: 0, title: 'Mix')].obs;
  RxBool isDropdownVisible = false.obs;
  RxBool isLoading = false.obs;
  bool isAnimation = false;

  @override
  void onInit() {
    super.onInit();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);
    animation = CurvedAnimation(parent: _controller, curve: Curves.linear);
    getPrefData();
  }

  @override
  void onReady() {
    super.onReady();
    fetchDoctorReels();
  }

  void getPrefData() async {
    SessionManager.instance.getCategories().forEach((element) {
      if (element.isDeleted == 0) {
        doctorCategories.add(element);
      }
    });
  }

  Future<void> fetchDoctorReels({bool isEmptyData = false}) async {
    isLoading.value = true;
    ApiService.instance.call(
      url: Urls.fetchReelsPatientApp,
      param: {
        pUserId: SessionManager.instance.getUserID(),
        if (selectedCategory.value.id != 0)
          pCategoryId: selectedCategory.value.id
      },
      completion: (response) {
        Reels data = Reels.fromJson(response);
        if (isEmptyData) {
          reels.value = [];
          if (Get.isRegistered<ReelsScreenController>(
              tag: ReelsScreenController.tag)) {
            var controller =
                Get.find<ReelsScreenController>(tag: ReelsScreenController.tag);
            controller.onRefreshPage(data.data ?? []);
          }
        }
        if (data.status == true) {
          reels.addAll(data.data ?? []);
        }
        isLoading.value = false;
      },
    );
  }

  toggleContainer() {
    if (animation.status != AnimationStatus.completed) {
      _controller.forward();
      isDropdownVisible.value = true;
    } else {
      _controller.animateBack(0,
          duration: const Duration(milliseconds: 250), curve: Curves.linear);
      isDropdownVisible.value = false;
    }
  }

  void onCategoryChanged({required Categories category}) {
    if (selectedCategory.value == category) return;
    selectedCategory.value = category;
    fetchDoctorReels(isEmptyData: true);
    toggleContainer();
  }
}
