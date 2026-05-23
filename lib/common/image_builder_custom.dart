import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class ImageBuilderCustom extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double? radius;
  final double? size;
  final Color? bgColor;
  final bool isDecorationVisible;
  final double? width;
  final BoxFit? fit;

  const ImageBuilderCustom(this.imageUrl,
      {super.key,
      this.name,
      this.radius,
      this.size,
      this.bgColor,
      this.isDecorationVisible = false,
      this.width,
      this.fit});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: isDecorationVisible
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: ColorRes.havelockBlue, width: 2))
          : null,
      child: ClipRRect(
        borderRadius:
            SmoothBorderRadius(cornerRadius: radius ?? 50, cornerSmoothing: 1),
        child: Image.network(
          '${ConstRes.itemBaseURL}$imageUrl',
          width: width ?? size ?? 45,
          height: size ?? 45,
          fit: fit ?? BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print(name);
            final displayText = (name?.isNotEmpty == true
                ? name
                : appName.isNotEmpty == true
                    ? appName
                    : "?");

            return Container(
              width: width ?? size ?? 45,
              height: size ?? 45,
              color: (bgColor ?? ColorRes.havelockBlue).withValues(alpha: .1),
              alignment: Alignment.center,
              child: Text(
                displayText![0].toUpperCase(),
                style: MyTextStyle.montserratSemiBold(
                    size: (size ?? 45) / 2,
                    color: (bgColor ?? ColorRes.havelockBlue)
                        .withValues(alpha: .7)),
              ),
            );
          },
        ),
      ),
    );
  }
}
