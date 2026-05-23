import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/utils/asset_res.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/font_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';
import 'package:patient_flutter/utils/update_res.dart';

class CustomUi {
  static void snackBar({String? message, Color? bgColor, Color? textColor}) {
    if (!Get.isSnackbarOpen) {
      Get.rawSnackbar(
        messageText: Text(
          (message ?? '').capitalizeFirst ?? '',
          style: MyTextStyle.montserratMedium(color: textColor ?? ColorRes.white, size: 14),
        ),
        snackPosition: SnackPosition.TOP,
        borderRadius: 10,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        backgroundColor: bgColor ?? ColorRes.havelockBlue,
        forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
      );
    }
  }

  static void infoSnackBar(
    String msg,
  ) {
    snackBar(message: msg);
  }

  static Future<void> loader() {
    return showDialog(
      context: Get.context!,
      // barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            color: ColorRes.havelockBlue,
          ),
        );
      },
    );
  }

  static Widget loaderWidget({Color? color}) {
    return Center(
      child: CircularProgressIndicator(color: color ?? ColorRes.havelockBlue),
    );
  }

  static Widget userPlaceHolder({int gender = 0, double height = 100}) {
    return Container(
      height: height,
      width: height,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: ColorRes.grey.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Image.asset(
        gender == 0 ? AssetRes.female : AssetRes.male,
        color: ColorRes.grey,
      ),
    );
  }

  static Widget ratingIndicator({required double rating, required double ratingSize}) {
    return RatingBarIndicator(
      itemCount: 5,
      itemSize: ratingSize,
      rating: rating,
      itemBuilder: (context, index) {
        return Icon(
          Icons.star_rate_rounded,
          color: ColorRes.mangoOrange,
          size: ratingSize,
        );
      },
    );
  }

  static Widget doctorPlaceHolder({int? gender = 0, double height = 100, double radius = 10}) {
    return Container(
      height: height,
      width: height,
      decoration: BoxDecoration(
        color: ColorRes.grey.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Image.asset(
        gender == 0 ? AssetRes.dFemale : AssetRes.dMale,
        color: ColorRes.grey,
      ),
    );
  }

  static String convert24HoursInto12Hours(String? value) {
    DateTime dateTime = DateTime(
      DateTime.now().year,
      1,
      1,
      int.parse(value?.substring(0, 2) ?? '0'),
      int.parse(value?.substring(2, 4) ?? '0'),
    );
    return DateFormat(hhMmA, 'en').format(dateTime);
  }

  static String dateFormat(String? date) {
    DateTime parseDate = DateFormat(
      yyyyMMDd,
    ).parse(date ?? '');
    var inputDate = DateTime.parse(parseDate.toString());
    var outputFormat = DateFormat(
      ddMMMYyyy,
    );
    String outputDate = outputFormat.format(inputDate);
    return outputDate;
  }

  static Widget noData({String? title}) {
    return Center(
      child: Text(
        title ?? S.current.noData,
        style: MyTextStyle.montserratMedium(color: ColorRes.battleshipGrey, size: 16),
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
          child: Image.asset(AssetRes.icEmptyData, width: size ?? Get.width / 1.5),
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
