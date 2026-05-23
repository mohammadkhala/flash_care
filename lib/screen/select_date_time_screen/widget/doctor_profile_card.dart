import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/doctor/fetch_doctor.dart';
import 'package:patient_flutter/utils/asset_res.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class DoctorProfileCard extends StatelessWidget {
  final bool isDividerVisible;
  final DoctorData? doctor;
  final double imageHeight;
  final double nameSize;
  final bool cardColor;

  const DoctorProfileCard({
    super.key,
    this.isDividerVisible = true,
    this.doctor,
    this.imageHeight = 100,
    this.nameSize = 19,
    this.cardColor = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: cardColor
          ? const EdgeInsets.symmetric(horizontal: 10, vertical: 5)
          : EdgeInsets.zero,
      decoration: cardColor
          ? BoxDecoration(
              color: ColorRes.whiteSmoke,
              borderRadius: BorderRadius.circular(10))
          : const BoxDecoration(),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: '${ConstRes.itemBaseURL}${doctor?.image}',
                  height: imageHeight,
                  width: imageHeight,
                  fit: BoxFit.cover,
                  errorWidget: (context, error, stackTrace) {
                    return CustomUi.doctorPlaceHolder(
                      height: imageHeight,
                      gender: doctor?.gender ?? 0,
                    );
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
                    Text(
                      doctor?.name ?? S.current.unKnown,
                      style: MyTextStyle.montserratExtraBold(
                              size: nameSize, color: ColorRes.black)
                          .copyWith(overflow: TextOverflow.ellipsis),
                    ),
                    SizedBox(
                      height: (nameSize - 11),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          AssetRes.stethoscope,
                          width: (nameSize),
                          height: (nameSize),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Text(
                            doctor?.designation ?? '',
                            style: MyTextStyle.montserratRegular(
                                size: 12, color: ColorRes.havelockBlue),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: (nameSize - 11),
                    ),
                    Text(
                      doctor?.degrees ?? '',
                      style: MyTextStyle.montserratRegular(
                          size: 12, color: ColorRes.battleshipGrey),
                    ),
                  ],
                ),
              )
            ],
          ),
          Visibility(
            visible: isDividerVisible,
            child: const Divider(
              thickness: 0.5,
              color: ColorRes.lightGrey,
            ),
          )
        ],
      ),
    );
  }
}
