import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/close_button_custom.dart';
import 'package:patient_flutter/common/text_button_custom.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/appointment_detail_screen/appointment_detail_screen_controller.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';
import 'package:patient_flutter/utils/update_res.dart';

class RatingSheet extends StatelessWidget {
  final AppointmentDetailScreenController controller;
  final VoidCallback onRatingSubmit;
  final Function(double rating) onRatingTap;

  const RatingSheet({
    super.key,
    required this.controller,
    required this.onRatingSubmit,
    required this.onRatingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 30, left: 15, right: 15, bottom: 10),
      margin: EdgeInsets.only(top: AppBar().preferredSize.height * 2),
      decoration: const BoxDecoration(
        color: ColorRes.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.current.addRatings,
                      style: MyTextStyle.montserratExtraBold(size: 20, color: ColorRes.charcoalGrey),
                    ),
                    Text(
                      S.current.shareYourExperienceEtc,
                      style: MyTextStyle.montserratLight(size: 16, color: ColorRes.davyGrey),
                    ),
                  ],
                ),
              ),
              const CloseButtonCustom()
            ],
          ),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RatingBar.builder(
                  initialRating: 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  itemCount: 5,
                  itemSize: 30,
                  unratedColor: ColorRes.silverChalice,
                  glowColor: Colors.transparent,
                  itemPadding: const EdgeInsets.only(left: 1, top: 50, right: 1, bottom: 15),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: ColorRes.mangoOrange,
                  ),
                  onRatingUpdate: onRatingTap,
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 120,
                        decoration: BoxDecoration(color: ColorRes.snowDrift, borderRadius: BorderRadius.circular(10)),
                        child: TextField(
                          controller: controller.ratingController,
                          expands: true,
                          minLines: null,
                          maxLines: null,
                          maxLength: 200,
                          onChanged: controller.onRatingChange,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(15),
                              isDense: true,
                              counterText: ''),
                          style: MyTextStyle.montserratMedium(size: 15, color: ColorRes.battleshipGrey),
                          cursorColor: ColorRes.battleshipGrey,
                          cursorHeight: 15,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      GetBuilder(
                        init: controller,
                        builder: (context) {
                          return Text(
                            '${controller.ratingController.text.length}/$ratingLength',
                            style: MyTextStyle.montserratRegular(size: 17, color: ColorRes.davyGrey),
                          );
                        },
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          )),
          SafeArea(
            top: false,
            child: TextButtonCustom(
                onPressed: onRatingSubmit,
                title: S.current.submit,
                titleColor: ColorRes.white,
                backgroundColor: ColorRes.darkSkyBlue),
          )
        ],
      ),
    );
  }
}
