import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:flutter/material.dart';

class CustomAnimatedBottomBar extends StatelessWidget {
  const CustomAnimatedBottomBar({
    super.key,
    this.selectedIndex = 0,
    this.showElevation = true,
    this.backgroundColor,
    this.containerHeight = 50,
    this.animationDuration = const Duration(milliseconds: 250),
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    required this.items,
    required this.onItemSelected,
    this.curve = Curves.linear,
  }) : assert(items.length >= 2 && items.length <= 5);

  final int selectedIndex;
  final Color? backgroundColor;
  final bool showElevation;
  final Duration animationDuration;
  final List<BottomNavyBarItem> items;
  final ValueChanged<int> onItemSelected;
  final MainAxisAlignment mainAxisAlignment;
  final double containerHeight;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorRes.white,
        boxShadow: [
          if (showElevation)
            BoxShadow(
                color: ColorRes.black.withValues(alpha: .06),
                blurRadius: 13,
                offset: const Offset(0, 0)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          height: containerHeight,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: items.map((item) {
              var index = items.indexOf(item);
              return GestureDetector(
                onTap: () => onItemSelected(index),
                child: _ItemWidget(
                  item: item,
                  isSelected: index == selectedIndex,
                  backgroundColor: ColorRes.white,
                  animationDuration: animationDuration,
                  curve: curve,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _ItemWidget extends StatelessWidget {
  final bool isSelected;
  final BottomNavyBarItem item;
  final Color backgroundColor;
  final Duration animationDuration;
  final Curve curve;

  const _ItemWidget({
    required this.isSelected,
    required this.item,
    required this.backgroundColor,
    required this.animationDuration,
    this.curve = Curves.linear,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: isSelected ? 150 : 40,
      height: double.maxFinite,
      duration: animationDuration,
      curve: curve,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: isSelected ? ColorRes.havelockBlue : null),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        // physics: const NeverScrollableScrollPhysics(),
        child: Container(
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(item.image,
                  height: 28,
                  width: 28,
                  color: isSelected ? ColorRes.white : ColorRes.starDust),
              const SizedBox(width: 5),
              if (isSelected)
                Container(
                  child: DefaultTextStyle.merge(
                    style: const TextStyle(
                        color: ColorRes.white,
                        fontFamily: FontRes.semiBold,
                        fontSize: 14),
                    maxLines: 1,
                    textAlign: item.textAlign,
                    child: Text(item.title),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomNavyBarItem {
  BottomNavyBarItem({
    required this.image,
    required this.title,
    this.textAlign,
  });

  final String image;
  final String title;
  final TextAlign? textAlign;
}
