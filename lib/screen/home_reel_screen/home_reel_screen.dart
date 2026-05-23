import 'package:doctor_flutter/model/doctor_category/doctor_category.dart';
import 'package:doctor_flutter/screen/home_reel_screen/home_reel_screen_controller.dart';
import 'package:doctor_flutter/screen/reels_screen/reels_screen.dart';
import 'package:doctor_flutter/utils/asset_res.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/const_res.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeReelScreen extends StatelessWidget {
  const HomeReelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeReelScreenController());
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ReelsScreen(
            reels: controller.reels,
            position: 0,
            isHomePage: true,
            isLoading: controller.isLoading,
            onFetchMoreData: controller.fetchDoctorReels,
            onRefresh: () => controller.fetchDoctorReels(isEmptyData: true),
            widget: DoctorCategoryDropDown(controller: controller)),
        Obx(() {
          return GestureDetector(
            onTap: !controller.isDropdownVisible.value
                ? null
                : () {
                    controller.toggleContainer();
                  },
            child: Container(
                color: !controller.isDropdownVisible.value
                    ? null
                    : Colors.black.withValues(alpha: 0.5)),
          );
        }),
        SafeArea(
          child: Obx(
            () {
              return Container(
                margin: EdgeInsets.only(top: 40)
                    .add(EdgeInsets.symmetric(horizontal: 20)),
                child: SizeTransition(
                  sizeFactor: controller.animation,
                  axis: Axis.vertical,
                  child: Column(
                    children: [
                      Center(
                        child: CustomPaint(
                          painter: TrianglePainter(
                            strokeColor: controller.reels.isEmpty
                                ? ColorRes.charcoalGrey
                                : ColorRes.white,
                            strokeWidth: 0,
                            paintingStyle: PaintingStyle.fill,
                          ),
                          child: const SizedBox(height: 9, width: 15),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxHeight: 200),
                        decoration: ShapeDecoration(
                          color: controller.reels.isEmpty
                              ? ColorRes.charcoalGrey
                              : ColorRes.white,
                          shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                                cornerRadius: 10, cornerSmoothing: 1),
                          ),
                        ),
                        child: Obx(
                          () {
                            return ListView.builder(
                              primary: false,
                              shrinkWrap: true,
                              itemCount: controller.doctorCategories.length,
                              itemBuilder: (context, index) {
                                final category =
                                    controller.doctorCategories[index];
                                return Obx(() => _buildCategoryItem(controller,
                                    category, index, controller.reels.isEmpty));
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildCategoryItem(HomeReelScreenController controller,
      DoctorCategoryData category, int index, bool isDataNotShow) {
    final isSelected = controller.selectedCategory.value.id == category.id;

    return Column(
      children: [
        InkWell(
          onTap: () => controller.onCategoryChanged(category: category),
          child: Container(
            height: 25,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    category.title?.capitalize ?? '',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: FontRes.bold,
                        color: isDataNotShow
                            ? (isSelected ? ColorRes.white : ColorRes.lightGrey)
                            : (isSelected
                                ? ColorRes.charcoalGrey
                                : ColorRes.battleshipGrey)),
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle,
                      color: isDataNotShow
                          ? ColorRes.white
                          : ColorRes.charcoalGrey,
                      size: 20),
              ],
            ),
          ),
        ),
        if (index < controller.doctorCategories.length - 1)
          const Divider(height: 1, color: ColorRes.battleshipGrey),
      ],
    );
  }
}

class DoctorCategoryDropDown extends StatelessWidget {
  final HomeReelScreenController controller;

  const DoctorCategoryDropDown({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (controller.doctorCategories.isNotEmpty) {
          controller.toggleContainer();
        }
      },
      child: Center(
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: ColorRes.white.withValues(alpha: 0.5)),
              color: ColorRes.white.withValues(alpha: 0.2)),
          child: Obx(() {
            DoctorCategoryData category = controller.selectedCategory.value;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                if (category.id != 0)
                  Image.network('${ConstRes.itemBaseURL}${category.image}',
                      height: 17,
                      width: 17,
                      fit: BoxFit.cover,
                      color: ColorRes.white),
                Flexible(
                  child: Text(
                    category.title ?? '',
                    style: const TextStyle(
                        fontSize: 14,
                        fontFamily: FontRes.regular,
                        color: ColorRes.white),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Image.asset(AssetRes.icDownArrow,
                    color: ColorRes.white, height: 10, width: 10),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  TrianglePainter(
      {this.strokeColor = Colors.black,
      this.strokeWidth = 3,
      this.paintingStyle = PaintingStyle.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = paintingStyle;

    canvas.drawPath(getTrianglePath(size.width, size.height), paint);
  }

  Path getTrianglePath(double x, double y) {
    return Path()
      ..moveTo(0, y)
      ..lineTo(x / 2, 0)
      ..lineTo(x, y)
      ..lineTo(0, y);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.paintingStyle != paintingStyle ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
