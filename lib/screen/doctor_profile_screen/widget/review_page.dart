import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:patient_flutter/common/common_fun.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/doctor/doctor_review.dart';
import 'package:patient_flutter/screen/doctor_profile_screen/doctor_profile_screen_controller.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';
import 'package:patient_flutter/utils/update_res.dart';

class ReviewPage extends StatelessWidget {
  final DoctorProfileScreenController controller;

  const ReviewPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: ColorRes.snowDrift,
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Text(
                '${controller.doctorData?.rating.toString().replaceAll('0.0', '0') ?? 0}',
                style: MyTextStyle.montserratLight(
                    size: 29, color: ColorRes.davyGrey),
              ),
              const SizedBox(
                height: 5,
              ),
              CustomUi.ratingIndicator(
                  rating: controller.doctorData?.rating ?? 0, ratingSize: 25),
              const SizedBox(
                height: 5,
              ),
              Text(
                '${controller.review.length} ${S.current.ratings}',
                style: MyTextStyle.montserratLight(
                    size: 14, color: ColorRes.smokeyGrey),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        ListView.builder(
          primary: false,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: controller.review.length,
          itemBuilder: (context, index) {
            DoctorReviewData? review = controller.review[index];
            return Container(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 7),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipOval(
                        child: CachedNetworkImage(
                          imageUrl:
                              '${ConstRes.itemBaseURL}${review.user?.profileImage}',
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                          errorWidget: (context, error, stackTrace) {
                            return CustomUi.doctorPlaceHolder(
                                height: 55,
                                gender: controller.doctorData?.gender);
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    review.user?.fullname ?? S.current.unKnown,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: MyTextStyle.montserratSemiBold(
                                      size: 16,
                                      color: ColorRes.davyGrey,
                                    ),
                                  ),
                                ),
                                Text(
                                  CommonFun.timeAgo(DateTime.parse(
                                      review.createdAt ?? createdDate)),
                                  style: MyTextStyle.montserratMedium(
                                      size: 13, color: ColorRes.silverChalice),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            CustomUi.ratingIndicator(
                                rating: review.rating?.toDouble() ?? 0,
                                ratingSize: 20),
                            const SizedBox(
                              height: 3,
                            ),
                            Text(
                              review.comment ?? '',
                              style: MyTextStyle.montserratRegular(
                                  size: 14, color: ColorRes.battleshipGrey),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(
                    thickness: 1,
                  )
                ],
              ),
            );
          },
        )
      ],
    );
  }
}
