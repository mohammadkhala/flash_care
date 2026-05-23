import 'package:doctor_flutter/screen/dashboard_screen/dashboard_screen_controller.dart';
import 'package:doctor_flutter/screen/message_screen/message_screen.dart';
import 'package:doctor_flutter/utils/asset_res.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopBarTab extends StatelessWidget {
  final String title;

  const TopBarTab({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorRes.whiteSmoke,
      width: double.infinity,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 20),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Expanded(
              child: Text(title.toUpperCase(),
                  style: const TextStyle(
                      color: ColorRes.charcoalGrey, fontSize: 18)),
            ),
            const MessageIcon(),
          ],
        ),
      ),
    );
  }
}

class MessageIcon extends StatelessWidget {
  const MessageIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardScreenController>();
    return InkWell(
      onTap: () {
        Get.to(() => const MessageScreen());
      },
      child: Container(
        width: 50,
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 45,
              width: 45,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: ColorRes.havelockBlue.withValues(alpha: .1)),
              child: Image.asset(
                AssetRes.chatQuote,
                color: ColorRes.havelockBlue,
              ),
            ),
            Obx(
              () => controller.unReadMessages.isEmpty
                  ? const SizedBox()
                  : Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        height: 20,
                        width: 20,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: ColorRes.bittersweet),
                        alignment: Alignment.center,
                        child: Text(
                          '${controller.unReadMessages.length}',
                          style: const TextStyle(
                              fontFamily: FontRes.regular,
                              color: ColorRes.white,
                              fontSize: 12),
                        ),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
