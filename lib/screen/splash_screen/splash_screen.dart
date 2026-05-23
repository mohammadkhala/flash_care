import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/splash_screen/splash_screen_controller.dart';
import 'package:patient_flutter/utils/asset_res.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/font_res.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SplashScreenController();

    return Scaffold(
      backgroundColor: ColorRes.havelockBlue,
      body: GetBuilder(
          init: controller,
          tag: '${DateTime.now().millisecondsSinceEpoch}',
          builder: (controller) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Row(),
                SizedBox(
                  width: Get.width / 2,
                  height: Get.width / 2,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: Get.width / 2,
                        height: Get.width / 2,
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(color: ColorRes.white.withValues(alpha: .1), blurRadius: 70)
                        ]),
                      ),
                      Image.asset(
                        AssetRes.icSplash,
                        width: 220,
                        height: 269,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  appName,
                  style: TextStyle(fontFamily: FontRes.black, fontSize: 25, color: ColorRes.white),
                ),
                const SizedBox(height: 10),
                Text(
                  S.of(context).findDoctorsBookAppointmentEtc,
                  style: const TextStyle(
                      fontFamily: FontRes.light, color: ColorRes.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppBar().preferredSize.height / 1.8),
                SafeArea(
                  top: false,
                  child: CustomUi.loaderWidget(color: ColorRes.white),
                ),
                SizedBox(height: AppBar().preferredSize.height / 1.8),
              ],
            );
          }),
    );
  }
}
