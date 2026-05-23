import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctor_flutter/screen/video_call_screen/video_call_screen.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/const_res.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:flutter/material.dart';

class LocalPlaceHolder extends StatelessWidget {
  final String image;
  final String name;
  final double? size;

  const LocalPlaceHolder({super.key, required this.image, required this.name, this.size});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: '${ConstRes.itemBaseURL}$image',
      cacheKey: '${ConstRes.itemBaseURL}$image',
      width: size ?? 100,
      height: size ?? 100,
      fit: BoxFit.cover,
      errorWidget: (context, error, stackTrace) {
        return Container(
          color: ColorRes.grey,
          alignment: Alignment.center,
          child: Text(
            name,
            style: const TextStyle(color: ColorRes.white, fontSize: 70, fontFamily: FontRes.black),
          ),
        );
      },
    );
  }
}

class RemotePlaceHolder extends StatelessWidget {
  final String image;
  final String name;
  final Widget? widget;

  const RemotePlaceHolder({super.key, required this.image, required this.name, this.widget});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.network(
          '${ConstRes.itemBaseURL}$image',
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return BlurImageTextCard(
              name: name,
              bg: Colors.black,
              size: 200,
            );
          },
          fit: BoxFit.cover,
        ),
        widget ?? const SizedBox()
      ],
    );
  }
}
