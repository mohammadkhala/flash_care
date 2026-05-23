import 'package:doctor_flutter/screen/home_reel_screen/home_reel_screen_controller.dart';
import 'package:doctor_flutter/utils/asset_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReelsTopBar extends StatelessWidget {
  final HomeReelScreenController controller;
  final Widget? widget;

  const ReelsTopBar({super.key, required this.controller, this.widget});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(AssetRes.icBackArrow, width: 30, height: 30),
                if (widget != null) Flexible(child: widget!),
                Obx(() {
                  if (controller.reels.isEmpty) {
                    return const SizedBox(width: 30, height: 30);
                  }

                  return InkWell(
                    onTap: () {},
                    child:
                        Image.asset(AssetRes.icReport, width: 30, height: 30),
                  );
                })
              ],
            ),
          ),
        ),
      ],
    );
  }
}
