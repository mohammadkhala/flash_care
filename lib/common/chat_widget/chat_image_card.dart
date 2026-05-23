import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/screen/image_preview_screen/image_preview_screen.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class ChatImageCard extends StatelessWidget {
  final String? imageUrl;
  final String? time;
  final String? msg;
  final EdgeInsets margin;
  final Color imageCardColor;
  final Color imageTextColor;

  const ChatImageCard(
      {super.key,
      this.imageUrl,
      this.time,
      this.msg,
      required this.margin,
      required this.imageCardColor,
      required this.imageTextColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: imageCardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      margin: margin,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Get.to(() => ImagePreviewScreen(imageUrl: imageUrl));
            },
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: Get.width / 1.6,
                maxHeight: Get.width / 1.6,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
                  imageUrl: '${ConstRes.itemBaseURL}$imageUrl',
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) {
                    return Container();
                  },
                ),
              ),
            ),
          ),
          Visibility(
            visible: msg == null || msg!.isEmpty ? false : true,
            child: Container(
              padding: const EdgeInsets.all(5),
              constraints: BoxConstraints(
                minWidth: Get.width / 2,
                maxWidth: Get.width / 2,
              ),
              child: Text(
                msg ?? '',
                style: MyTextStyle.montserratRegular(size: 14, color: imageTextColor),
              ),
            ),
          )
        ],
      ),
    );
  }
}
