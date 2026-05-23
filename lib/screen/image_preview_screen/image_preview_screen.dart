import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:photo_view/photo_view.dart';

class ImagePreviewScreen extends StatelessWidget {
  final String? imageUrl;

  const ImagePreviewScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.black,
      body: Stack(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PhotoView(
            imageProvider: CachedNetworkImageProvider('${ConstRes.itemBaseURL}$imageUrl',
                cacheKey: '${ConstRes.itemBaseURL}$imageUrl'),
          ),
          Positioned(
            top: 50,
            child: InkWell(
              onTap: () {
                Get.back();
              },
              child: Container(
                width: 38,
                height: 38,
                margin: const EdgeInsets.only(left: 20, top: 10),
                decoration: BoxDecoration(
                  color: ColorRes.havelockBlue.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: ColorRes.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
