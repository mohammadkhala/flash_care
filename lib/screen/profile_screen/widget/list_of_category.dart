import 'package:doctor_flutter/screen/profile_screen/profile_screen_controller.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:flutter/material.dart';

class ProfileCategory extends StatelessWidget {
  final ProfileScreenController controller;

  const ProfileCategory({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.list.length,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => controller.onCategoryChange(index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: controller.selectedCategory.value == index
                    ? ColorRes.tuftsBlue
                    : ColorRes.whiteSmoke,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                controller.list[index],
                style: TextStyle(
                  color: controller.selectedCategory.value == index
                      ? ColorRes.white
                      : ColorRes.starDust,
                  fontFamily: FontRes.semiBold,
                  fontSize: 15,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
