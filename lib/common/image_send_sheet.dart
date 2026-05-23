import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class ImageSendSheet extends StatelessWidget {
  final String image;
  final Function(String image) onSendMediaTap;
  final TextEditingController sendMediaController;

  const ImageSendSheet(
      {super.key, required this.image, required this.onSendMediaTap, required this.sendMediaController});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Wrap(
      children: [
        Container(
          margin: EdgeInsets.only(top: AppBar().preferredSize.height),
          padding: EdgeInsets.only(top: 15, left: 10, right: 10, bottom: bottomInset),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Text(
                        S.current.sendMedia,
                        style: MyTextStyle.montserratExtraBold(size: 19, color: ColorRes.charcoalGrey),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Container(
                            height: 38,
                            width: 38,
                            margin: const EdgeInsets.only(left: 10),
                            decoration: const BoxDecoration(color: ColorRes.iceberg, shape: BoxShape.circle),
                            child: const Icon(
                              Icons.close_rounded,
                              color: ColorRes.charcoalGrey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(thickness: 1),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(
                        File(image),
                        height: Get.width / 2,
                        width: Get.width / 2.6,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.medium,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: ColorRes.grey,
                          height: Get.width / 2,
                          width: Get.width / 2.6,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: Get.width / 2,
                        decoration: BoxDecoration(color: ColorRes.snowDrift, borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: TextField(
                          controller: sendMediaController,
                          expands: true,
                          maxLines: null,
                          minLines: null,
                          cursorColor: ColorRes.charcoalGrey,
                          cursorHeight: 15,
                          style: MyTextStyle.montserratMedium(size: 15, color: ColorRes.charcoalGrey),
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => onSendMediaTap(''),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: ColorRes.darkSkyBlue, borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      S.current.send,
                      style: MyTextStyle.montserratSemiBold(size: 18, color: ColorRes.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        )
      ],
    );
  }
}
