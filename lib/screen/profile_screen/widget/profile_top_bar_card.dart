import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/utils/asset_res.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/extention.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileTopBarCard extends StatelessWidget {
  final Rx<DoctorData?> doctorData;

  const ProfileTopBarCard({super.key, required this.doctorData});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorRes.white,
        boxShadow: [
          BoxShadow(
              color: ColorRes.black.withValues(alpha: .08),
              blurRadius: 14.0, // soften the shadow
              offset: const Offset(0, 1.0))
        ],
      ),
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    doctorData.value?.name ?? S.current.unKnown,
                    style: const TextStyle(
                      fontFamily: FontRes.extraBold,
                      color: ColorRes.charcoalGrey,
                      fontSize: 23,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 5),
                if (doctorData.value?.rating != null &&
                    doctorData.value?.rating?.toInt() != 0)
                  const DoctorRatingBadge(
                    rating: 5,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Image.asset(AssetRes.stethoscope, width: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    doctorData.value?.designation ??
                        S.current.addYourDesignation,
                    style: const TextStyle(
                        color: ColorRes.havelockBlue, fontSize: 15),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Text(
              doctorData.value?.degrees ?? S.current.addYourDegreesEtc,
              style: const TextStyle(fontSize: 14, color: ColorRes.mediumGrey),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 13.0),
              child:
                  Divider(thickness: 1, height: 1, color: ColorRes.softPeach),
            ),
            Row(
              children: [
                const Icon(Icons.location_on,
                    color: ColorRes.havelockBlue, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    doctorData.value?.clinicAddress ?? S.current.noAddressFound,
                    style: const TextStyle(
                        fontSize: 14, color: ColorRes.mediumGrey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                PortfolioCard(
                  title1: "${doctorData.value?.experienceYear ?? '0'}",
                  title2: S.current.years,
                  category: S.current.experience,
                ),
                const SizedBox(width: 10),
                PortfolioCard(
                  title1: (doctorData.value?.totalPatientsCured ?? 0)
                      .formatCurrency,
                  title2: "",
                  category: S.current.happyPatients,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class PortfolioCard extends StatelessWidget {
  final String title1;
  final String title2;
  final String category;

  const PortfolioCard(
      {super.key,
      required this.title1,
      required this.title2,
      required this.category});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: ColorRes.whiteSmoke.withValues(alpha: 0.7)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: title1,
                style: const TextStyle(
                    color: ColorRes.charcoalGrey,
                    fontFamily: FontRes.bold,
                    fontSize: 17),
                children: [
                  TextSpan(
                    text: " $title2",
                    style: const TextStyle(
                      color: ColorRes.charcoalGrey,
                      fontSize: 13,
                      fontFamily: FontRes.regular,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 5),
            Text(
              category.toUpperCase(),
              style: const TextStyle(
                  color: ColorRes.havelockBlue,
                  fontSize: 12,
                  fontFamily: FontRes.medium,
                  overflow: TextOverflow.ellipsis,
                  letterSpacing: 0.5),
            )
          ],
        ),
      ),
    );
  }
}

class DoctorRatingBadge extends StatelessWidget {
  final double rating;

  const DoctorRatingBadge({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: ColorRes.mangoOrange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            rating.toStringAsFixed(1).replaceAll('0.0', '0'),
            style: const TextStyle(
                color: ColorRes.mangoOrange,
                fontSize: 18,
                fontFamily: FontRes.semiBold),
          ),
          const SizedBox(width: 5),
          const Icon(
            Icons.star,
            size: 20,
            color: ColorRes.mangoOrange,
          ),
        ],
      ),
    );
  }
}
