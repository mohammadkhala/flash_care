import 'package:flutter/material.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/font_res.dart';

class MyTextStyle {
  static TextStyle montserratBlack({double? size, Color? color}) {
    return TextStyle(
        fontFamily: FontRes.black,
        fontSize: size ?? 16,
        color: color ?? ColorRes.black);
  }

  static TextStyle montserratBold({double? size, Color? color}) {
    return TextStyle(
        fontFamily: FontRes.bold,
        fontSize: size ?? 16,
        color: color ?? ColorRes.black);
  }

  static TextStyle montserratExtraBold({double? size, Color? color}) {
    return TextStyle(
        fontFamily: FontRes.extraBold,
        fontSize: size ?? 16,
        color: color ?? ColorRes.black);
  }

  static TextStyle montserratLight({double? size, Color? color}) {
    return TextStyle(
        fontFamily: FontRes.light,
        fontSize: size ?? 16,
        color: color ?? ColorRes.black);
  }

  static TextStyle montserratMedium({double? size, Color? color}) {
    return TextStyle(
        fontFamily: FontRes.medium,
        fontSize: size ?? 16,
        color: color ?? ColorRes.black);
  }

  static TextStyle montserratRegular({double? size, Color? color}) {
    return TextStyle(
        fontFamily: FontRes.regular,
        fontSize: size ?? 16,
        color: color ?? ColorRes.black);
  }

  static TextStyle montserratSemiBold({double? size, Color? color}) {
    return TextStyle(
      fontFamily: FontRes.semiBold,
      fontSize: size ?? 16,
      color: color ?? ColorRes.black,
    );
  }

  static TextStyle montserratThin({double? size, Color? color}) {
    return TextStyle(
        fontFamily: FontRes.thin,
        fontSize: size ?? 16,
        color: color ?? ColorRes.black);
  }

  // PhysioHub teal brand gradient
  static const linearTopGradient = LinearGradient(
    colors: [
      Color(0xFF26A69A), // teal 400
      Color(0xFF00695C), // teal 800
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const linearLeftGradient = LinearGradient(
      colors: [Color(0xFF26A69A), Color(0xFF00695C)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight);

  static const linearBottomGradient = LinearGradient(
    colors: [
      Color(0xFF00695C),
      Color(0xFF26A69A),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const linearGreyGradient = LinearGradient(
    colors: [
      ColorRes.whiteSmoke,
      ColorRes.whiteSmoke,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
