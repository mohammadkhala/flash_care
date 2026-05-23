import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/utils/asset_res.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/extention.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomUi {
  static void snackBar({String? message, Color? bgColor, Color? textColor}) {
    if (Get.isSnackbarOpen) return;
    Get.rawSnackbar(
      messageText: Text(
        (message?.capitalize ?? '').capitalizeFirst ?? '',
        style: TextStyle(
            color: textColor ?? ColorRes.white,
            fontFamily: FontRes.medium,
            fontSize: 14),
      ),
      snackPosition: SnackPosition.TOP,
      borderRadius: 10,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      backgroundColor: bgColor ?? ColorRes.havelockBlue,
      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static void snackBarMaterial(String? titleName) {
    final ctx = Get.context;
    if (ctx == null) return;
    try {
      ScaffoldMessenger.of(ctx)
          .showSnackBar(
            SnackBar(
              content: Text(
                (titleName ?? '').capitalizeFirst ?? '',
                style: const TextStyle(
                    color: ColorRes.white,
                    fontFamily: FontRes.medium,
                    fontSize: 14),
                maxLines: 2,
              ),
              backgroundColor: ColorRes.havelockBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 5,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(milliseconds: 2500),
            ),
          )
          .closed
          .then((_) {
        final c = Get.context;
        if (c != null) {
          try {
            ScaffoldMessenger.of(c).clearSnackBars();
          } catch (_) {}
        }
      });
    } catch (_) {}
  }

  static void loader() {
    Get.dialog(const Center(
      child: CircularProgressIndicator(
        color: ColorRes.havelockBlue,
      ),
    ));
  }

  static Widget loaderWidget({Color? color}) {
    return Center(
      child: CircularProgressIndicator(color: color ?? ColorRes.havelockBlue),
    );
  }

  static Widget userPlaceHolder({required num male, double height = 100}) {
    return Container(
      color: ColorRes.battleshipGrey.withValues(alpha: 0.2),
      height: height,
      width: height,
      padding: const EdgeInsets.all(5),
      child: Image.asset(
        male.genderParse == 1 ? AssetRes.male : AssetRes.feMale,
        height: height,
        width: height,
        color: ColorRes.grey,
      ),
    );
  }

  static Widget doctorPlaceHolder({int? male = 1, double height = 100}) {
    return Container(
      color: ColorRes.whiteSmoke,
      height: height,
      width: height,
      padding: const EdgeInsets.all(5),
      child: Image.asset(
        male == 1 ? AssetRes.p1 : AssetRes.p2,
        height: height,
        width: height,
      ),
    );
  }

  static Widget noData({String? message}) {
    return Center(
      child: Text(
        message ?? S.current.noData,
        style: const TextStyle(
            color: ColorRes.nobel, fontFamily: FontRes.medium, fontSize: 15),
      ),
    );
  }

  static Widget noDataImage({double? size, String? message}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Row(),
        SizedBox(
          width: size ?? 100,
          height: size ?? 100,
          child:
              Image.asset(AssetRes.icEmptyData, width: size ?? Get.width / 1.5),
        ),
        const SizedBox(height: 10),
        Text(
          message ?? S.current.noData,
          style: const TextStyle(
            color: ColorRes.nobel,
            fontFamily: FontRes.medium,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
