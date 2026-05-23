import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/doctor/fetch_doctor.dart';
import 'package:patient_flutter/screen/doctor_profile_screen/doctor_profile_screen_controller.dart';
import 'package:patient_flutter/screen/doctor_profile_screen/widget/award_page.dart';
import 'package:patient_flutter/screen/doctor_profile_screen/widget/stats_page.dart';
import 'package:patient_flutter/screen/doctor_profile_screen/widget/detail_page.dart';
import 'package:patient_flutter/screen/doctor_profile_screen/widget/doctor_profile_card.dart';
import 'package:patient_flutter/screen/doctor_profile_screen/widget/education_page.dart';
import 'package:patient_flutter/screen/doctor_profile_screen/widget/experience_page.dart';
import 'package:patient_flutter/screen/doctor_profile_screen/widget/list_of_category.dart';
import 'package:patient_flutter/screen/doctor_profile_screen/widget/reel_page.dart';
import 'package:patient_flutter/screen/doctor_profile_screen/widget/review_page.dart';
import 'package:patient_flutter/screen/select_date_time_screen/select_date_time_screen.dart';
import 'package:patient_flutter/utils/asset_res.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/extention.dart';
import 'package:patient_flutter/utils/font_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';
import 'package:patient_flutter/utils/update_res.dart';

class DoctorProfileScreen extends StatelessWidget {
  final DoctorData? doctorData;

  const DoctorProfileScreen({super.key, required this.doctorData});

  @override
  Widget build(BuildContext context) {
    final controller = DoctorProfileScreenController(doctorData);
    return GetBuilder(
      init: controller,
      tag: '${DateTime.now().millisecondsSinceEpoch}',
      builder: (controller) => Scaffold(
        backgroundColor: ColorRes.white,
        body: CustomScrollView(
          controller: controller.scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            GetBuilder(
              init: controller,
              builder: (controller) {
                var temp = (controller.currentExtent * 0.233333);
                var size = temp < 35.0 ? 35.0 : temp;
                var o = (-1 * (size - 70)) * 0.02857143;
                var opacity = 1 - (o > 1.0 ? 1.0 : o);
                return SliverAppBar(
                  pinned: true,
                  backgroundColor: Colors.white,
                  expandedHeight: controller.maxExtent,
                  collapsedHeight: 60,
                  stretch: true,
                  shadowColor: Colors.transparent,
                  leadingWidth: 0,
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    expandedTitleScale: 1,
                    titlePadding: const EdgeInsets.all(0),
                    collapseMode: CollapseMode.pin,
                    title: Stack(
                      children: [
                        Stack(
                          alignment: Alignment.bottomLeft,
                          children: [
                            Container(
                              color: ColorRes.white,
                              padding: EdgeInsets.only(
                                bottom: 10,
                                left: Directionality.of(context) ==
                                        TextDirection.rtl
                                    ? 0.0
                                    : opacity > .8
                                        ? 10
                                        : (1 - opacity) * 56,
                                right: Directionality.of(context) !=
                                        TextDirection.rtl
                                    ? 0.0
                                    : opacity > .8
                                        ? 10
                                        : (1 - opacity) * 56,
                                top: 10,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      controller.doctorData?.name ??
                                          S.current.unKnown,
                                      style: const TextStyle(
                                          fontFamily: FontRes.extraBold,
                                          color: ColorRes.charcoalGrey,
                                          fontSize: 19),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (controller.doctorData?.rating != null ||
                                      controller.doctorData?.rating?.toInt() !=
                                          0)
                                    Opacity(
                                      opacity: opacity,
                                      child: Container(
                                        height: 28,
                                        width: 70,
                                        decoration: BoxDecoration(
                                          color: ColorRes.mangoOrange
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              controller.doctorData?.rating
                                                      ?.toStringAsFixed(1)
                                                      .replaceAll('0.0', '0') ??
                                                  '',
                                              style: const TextStyle(
                                                color: ColorRes.mangoOrange,
                                                fontSize: 18,
                                                fontFamily: FontRes.semiBold,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            const Icon(
                                              Icons.star,
                                              size: 15,
                                              color: ColorRes.mangoOrange,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Column()
                          ],
                        ),
                        SafeArea(
                          bottom: false,
                          child: Align(
                            alignment:
                                Directionality.of(context) == TextDirection.rtl
                                    ? Alignment.topRight
                                    : Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  right: 10, left: 7, top: 20),
                              child: InkWell(
                                onTap: () {
                                  Get.back(result: controller.isBackFavDoc);
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                      color: ColorRes.white,
                                      shape: BoxShape.circle),
                                  padding: const EdgeInsets.all(5),
                                  child: const Icon(
                                    Icons.arrow_back_rounded,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SafeArea(
                          bottom: false,
                          child: Align(
                            alignment:
                                Directionality.of(context) == TextDirection.rtl
                                    ? Alignment.topLeft
                                    : Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  right: 15, left: 7, top: 20),
                              child: InkWell(
                                onTap: controller.updateProfileApiCall,
                                child: GetBuilder(
                                  init: controller,
                                  builder: (context) {
                                    return Container(
                                      decoration: const BoxDecoration(
                                          color: ColorRes.white,
                                          shape: BoxShape.circle),
                                      padding: const EdgeInsets.all(5),
                                      child: Icon(
                                          controller.isFavouriteId
                                              ? Icons.bookmark
                                              : Icons.bookmark_border_rounded,
                                          color: controller.isFavouriteId
                                              ? ColorRes.havelockBlue
                                              : Colors.black),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    stretchModes: const [
                      StretchMode.zoomBackground,
                    ],
                    background: controller.doctorData?.image != null
                        ? CachedNetworkImage(
                            imageUrl:
                                '${ConstRes.itemBaseURL}${controller.doctorData?.image}',
                            cacheKey:
                                '${ConstRes.itemBaseURL}${controller.doctorData?.image}',
                            fit: BoxFit.cover,
                            errorWidget: (context, error, stackTrace) {
                              return CustomUi.doctorPlaceHolder(
                                  gender: controller.doctorData?.gender,
                                  radius: 0);
                            },
                          )
                        : CustomUi.doctorPlaceHolder(
                            gender: controller.doctorData?.gender, radius: 0),
                  ),
                );
              },
            ),
            SliverToBoxAdapter(
              child: GetBuilder(
                init: controller,
                builder: (context) {
                  return controller.isLoading
                      ? CustomUi.loaderWidget()
                      : Column(
                          children: [
                            DoctorProfileCard(data: controller.doctorData),
                            const SizedBox(
                              height: 10,
                            ),
                            ListOfCategory(
                              categories: controller.list,
                              onCategoryChange: controller.onCategoryChange,
                              selectedCategoryIndex:
                                  controller.selectedCategoryIndex,
                            ),
                            const SizedBox(height: 10),
                            controller.selectedCategoryIndex == 0
                                ? DetailPage(controller: controller)
                                : controller.selectedCategoryIndex == 1
                                    ? ReelPage(controller: controller)
                                    : controller.selectedCategoryIndex == 2
                                        ? ReviewPage(controller: controller)
                                        : controller.selectedCategoryIndex == 3
                                            ? EducationPage(
                                                controller: controller)
                                            : controller.selectedCategoryIndex ==
                                                    4
                                                ? ExperiencePage(
                                                    controller: controller)
                                                : controller.selectedCategoryIndex ==
                                                        5
                                                    ? AwardPage(
                                                        controller: controller)
                                                    : StatsPage(
                                                        controller:
                                                            controller),
                            SizedBox(height: AppBar().preferredSize.height),
                          ],
                        );
                },
              ),
            )
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            gradient: MyTextStyle.linearTopGradient,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
          ),
          child: SafeArea(
            top: false,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.to(
                            () => const SelectDateTimeScreen(addAppointment: 0),
                            arguments: [controller.doctorData, null]);
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                            color: ColorRes.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.all(10),
                        alignment: Alignment.center,
                        child: GetBuilder(
                          init: controller,
                          builder: (context) {
                            return RichText(
                              text: TextSpan(
                                text: '${S.current.bookNow} :',
                                style: MyTextStyle.montserratSemiBold(
                                    color: ColorRes.white),
                                children: [
                                  TextSpan(
                                    text:
                                        '$dollar${(controller.doctorData?.consultationFee ?? 0).numFormat}',
                                    style: MyTextStyle.montserratExtraBold(
                                        color: ColorRes.white),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  InkWell(
                    onTap: controller.onChatBtnTap,
                    child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            color: ColorRes.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.all(14),
                        child: Image.asset(AssetRes.icFillComment)),
                  ),
                  const SizedBox(width: 15),
                  Visibility(
                    visible:
                        (controller.doctorData?.mobileNumber ?? '').isNotEmpty,
                    child: InkWell(
                      onTap: controller.onCallBtnTap,
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: ColorRes.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: const Icon(
                          Icons.call_rounded,
                          color: ColorRes.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
