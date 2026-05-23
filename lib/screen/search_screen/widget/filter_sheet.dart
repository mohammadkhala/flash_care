import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/close_button_custom.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/search_screen/search_screen_controller.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class FilterSheet extends StatelessWidget {
  final SearchScreenController controller;

  const FilterSheet({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: AppBar().preferredSize.height * 2),
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      decoration: const BoxDecoration(
        color: ColorRes.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    S.current.applySearchFilters,
                    style: MyTextStyle.montserratExtraBold(size: 20, color: ColorRes.charcoalGrey),
                  ),
                ),
                const CloseButtonCustom()
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.current.gender,
                  style: MyTextStyle.montserratRegular(size: 15, color: ColorRes.battleshipGrey),
                ),
                const SizedBox(
                  height: 10,
                ),
                GetBuilder(
                  init: controller,
                  builder: (controller) {
                    return Wrap(
                      children: List.generate(
                        controller.genderList.length,
                        (index) {
                          return InkWell(
                            onTap: () {
                              controller.onGenderTap(index);
                            },
                            child: Card(
                              elevation: controller.selectedGender == index ? 2 : 0,
                              color: controller.selectedGender == index ? ColorRes.havelockBlue : ColorRes.softPeach,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  controller.genderList[index].toUpperCase(),
                                  style: MyTextStyle.montserratSemiBold(
                                          size: 12,
                                          color: controller.selectedGender == index
                                              ? ColorRes.white
                                              : ColorRes.charcoalGrey)
                                      .copyWith(letterSpacing: 0.5),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                )
              ],
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.current.category,
                  style: MyTextStyle.montserratRegular(size: 13, color: ColorRes.battleshipGrey),
                ),
                const SizedBox(
                  height: 10,
                ),
                GetBuilder(
                  init: controller,
                  builder: (controller) {
                    return Wrap(
                      children: List.generate(
                        controller.categories?.length ?? 0,
                        (index) {
                          return InkWell(
                            onTap: () {
                              controller.onCategoryTap(index, controller.categories?[index]);
                            },
                            child: Card(
                              elevation: controller.selectCategoryIndex == index ? 2 : 0,
                              color:
                                  controller.selectCategoryIndex == index ? ColorRes.havelockBlue : ColorRes.softPeach,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  controller.categories?[index].title?.toUpperCase() ?? '',
                                  style: MyTextStyle.montserratSemiBold(
                                          size: 12,
                                          color: controller.selectCategoryIndex == index
                                              ? ColorRes.white
                                              : ColorRes.charcoalGrey)
                                      .copyWith(
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              S.current.sortBy,
              style: MyTextStyle.montserratRegular(size: 13, color: ColorRes.battleshipGrey),
            ),
          ),
          ListView.builder(
            itemCount: 3,
            primary: false,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                margin: const EdgeInsets.symmetric(vertical: 1),
                color: ColorRes.whiteSmoke,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.sortByList[index],
                        style: MyTextStyle.montserratSemiBold(
                          size: 14,
                          color: ColorRes.charcoalGrey,
                        ),
                      ),
                    ),
                    GetBuilder(
                      init: SearchScreenController(),
                      builder: (controller) {
                        return UnicornOutlineButton(
                          strokeWidth: 2,
                          radius: 30,
                          gradient: MyTextStyle.linearTopGradient,
                          child: Visibility(
                            visible: controller.selectedSortBy == index ? true : false,
                            child: Container(
                              height: 18,
                              width: 18,
                              decoration: const BoxDecoration(
                                gradient: MyTextStyle.linearTopGradient,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          onPressed: () {
                            controller.onSortByTap(index);
                          },
                        );
                      },
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class UnicornOutlineButton extends StatelessWidget {
  final _GradientPainter _painter;
  final Widget _child;
  final VoidCallback _callback;
  final double _radius;

  UnicornOutlineButton({
    super.key,
    required double strokeWidth,
    required double radius,
    required Gradient gradient,
    required Widget child,
    required VoidCallback onPressed,
  })  : _painter = _GradientPainter(strokeWidth: strokeWidth, radius: radius, gradient: gradient),
        _child = child,
        _callback = onPressed,
        _radius = radius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _painter,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _callback,
        child: InkWell(
          borderRadius: BorderRadius.circular(_radius),
          onTap: _callback,
          child: SizedBox(
            height: 25, width: 25,
            // constraints: const BoxConstraints(
            //     minWidth: 20, minHeight: 20, maxWidth: 20, maxHeight: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientPainter extends CustomPainter {
  final Paint _paint = Paint();
  final double radius;
  final double strokeWidth;
  final Gradient gradient;

  _GradientPainter({required this.strokeWidth, required this.radius, required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    // create outer rectangle equals size
    Rect outerRect = Offset.zero & size;
    var outerRRect = RRect.fromRectAndRadius(outerRect, Radius.circular(radius));

    // create inner rectangle smaller by strokeWidth
    Rect innerRect =
        Rect.fromLTWH(strokeWidth, strokeWidth, size.width - strokeWidth * 2, size.height - strokeWidth * 2);
    var innerRRect = RRect.fromRectAndRadius(innerRect, Radius.circular(radius - strokeWidth));

    // apply gradient shader
    _paint.shader = gradient.createShader(outerRect);

    // create difference between outer and inner paths and draw it
    Path path1 = Path()..addRRect(outerRRect);
    Path path2 = Path()..addRRect(innerRRect);
    var path = Path.combine(PathOperation.difference, path1, path2);
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}
