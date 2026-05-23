import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/const_res.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';

class ImageBuilderCustom extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double? radius;
  final double? size;
  final Color? bgColor;

  const ImageBuilderCustom(this.imageUrl,
      {super.key, this.name, this.radius, this.size, this.bgColor});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          SmoothBorderRadius(cornerRadius: radius ?? 50, cornerSmoothing: 1),
      child: Image.network(
        '${ConstRes.itemBaseURL}$imageUrl',
        width: size ?? 45,
        height: size ?? 45,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size ?? 45,
            height: size ?? 45,
            color: (bgColor ?? ColorRes.havelockBlue).withValues(alpha: .1),
            alignment: Alignment.center,
            child: Text(
              (name ?? appName)[0].toUpperCase(),
              style: TextStyle(
                  color: (bgColor ?? ColorRes.havelockBlue).withValues(alpha: .7),
                  fontSize: (size ?? 45) / 2,
                  fontFamily: FontRes.semiBold),
            ),
          );
        },
      ),
    );
  }
}
