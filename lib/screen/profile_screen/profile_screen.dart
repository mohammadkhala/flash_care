import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/common/image_builder_custom.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/screen/profile_screen/profile_screen_controller.dart';
import 'package:doctor_flutter/screen/profile_screen/widget/award_page.dart';
import 'package:doctor_flutter/screen/profile_screen/widget/detail_page.dart';
import 'package:doctor_flutter/screen/profile_screen/widget/education_page.dart';
import 'package:doctor_flutter/screen/profile_screen/widget/experience_page.dart';
import 'package:doctor_flutter/screen/profile_screen/widget/list_of_category.dart';
import 'package:doctor_flutter/screen/profile_screen/widget/profile_top_bar_card.dart';
import 'package:doctor_flutter/screen/profile_screen/widget/reel_page.dart';
import 'package:doctor_flutter/screen/profile_screen/widget/review_page.dart';
import 'package:doctor_flutter/service/session_manager.dart';
import 'package:doctor_flutter/utils/asset_res.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  final DoctorData? doctorData;

  const ProfileScreen({super.key, this.doctorData});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileScreenController(doctorData.obs);
    return GetBuilder(
      init: controller,
      tag: DateTime.now().millisecondsSinceEpoch.toString(),
      builder: (controller) {
        return Scaffold(
            backgroundColor: ColorRes.white,
            body: Stack(
              children: [
                Obx(
                  () => controller.isLoading.value
                      ? CustomUi.loaderWidget()
                      : CustomScrollView(
                          controller: controller.scrollController,
                          slivers: [
                            _buildSliverAppBar(controller),
                            SliverToBoxAdapter(
                              child: Column(
                                children: [
                                  ProfileTopBarCard(
                                      doctorData: controller.doctorData),
                                  ProfileCategory(controller: controller),
                                  _buildSelectedPage(controller),
                                  SizedBox(
                                      height: AppBar().preferredSize.height),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
            floatingActionButton: Obx(
              () {
                return controller.selectedCategory.value == 1
                    ? FloatingActionButton(
                        onPressed: controller.onAddReel,
                        backgroundColor: ColorRes.havelockBlue,
                        child: Image.asset(AssetRes.icReel,
                            height: 30, width: 30, color: ColorRes.white))
                    : const SizedBox();
              },
            ));
      },
    );
  }

  Widget _buildSelectedPage(controller) {
    switch (controller.selectedCategory.value) {
      case 0:
        return DetailPage(controller: controller);
      case 1:
        return ReelPage(controller: controller);
      case 2:
        return ExperiencePage(controller: controller);
      case 3:
        return EducationPage(controller: controller);
      case 4:
        return ReviewPage(controller: controller);
      default:
        return AwardPage(doctorData: controller.doctorData.value);
    }
  }

  // Build SliverAppBar with flexible space
  Widget _buildSliverAppBar(ProfileScreenController controller) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      expandedHeight: controller.maxExtent,
      stretch: true,
      shadowColor: Colors.transparent,
      leadingWidth: 0,
      titleTextStyle: const TextStyle(
          fontFamily: FontRes.extraBold,
          color: ColorRes.charcoalGrey,
          fontSize: 23),
      centerTitle: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              controller.opacity.value == 0
                  ? controller.doctorData.value?.name ?? S.current.unKnown
                  : '',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          DoctorSettingBtn(controller: controller)
        ],
      ),
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        expandedTitleScale: 1,
        titlePadding: EdgeInsets.zero,
        collapseMode: CollapseMode.pin,
        // title: SliverAppBarContent(controller: controller),
        stretchModes: const [StretchMode.zoomBackground],
        background: _buildSliverAppBarBackground(controller),
      ),
    );
  }

  // Build SliverAppBar background image
  Widget _buildSliverAppBarBackground(ProfileScreenController controller) {
    return ImageBuilderCustom(controller.doctorData.value?.image,
        name: controller.doctorData.value?.name, size: 200, radius: 0);
  }
}

class DoctorSettingBtn extends StatelessWidget {
  final ProfileScreenController controller;

  const DoctorSettingBtn({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return controller.doctorData.value?.id !=
            SessionManager.instance.getDoctorId()
        ? const SizedBox()
        : SafeArea(
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              child: Container(
                width: 45,
                height: 45,
                alignment: AlignmentDirectional.topEnd,
                padding: const EdgeInsets.all(10),
                child: InkWell(
                  onTap: controller.onSettingTap,
                  child: Obx(
                    () => Image.asset(AssetRes.icSetting,
                        color: controller.opacity.value > 0.01
                            ? Colors.white
                            : Colors.black),
                  ),
                ),
              ),
            ),
          );
  }
}
