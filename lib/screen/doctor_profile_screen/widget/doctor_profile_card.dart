import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/doctor/fetch_doctor.dart';
import 'package:patient_flutter/utils/asset_res.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/font_res.dart';

class DoctorProfileCard extends StatelessWidget {
  final DoctorData? data;

  const DoctorProfileCard({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ColorRes.white,
        boxShadow: [
          BoxShadow(
            color: ColorRes.softPeach,
            blurRadius: 5.0,
            spreadRadius: 1.0,
            offset: Offset(
              5.0, // Move to right 5  horizontally
              5.0, // Move to bottom 5 Vertically
            ),
          )
        ],
      ),
      child: Column(
        children: [
          _profileCard(),
        ],
      ),
    );
  }

  Widget _profileCard() {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                AssetRes.stethoscope,
                width: 21,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  data?.designation ?? '',
                  style: const TextStyle(
                    color: ColorRes.havelockBlue,
                    fontSize: 15,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            data?.degrees ?? '',
            style: const TextStyle(fontSize: 14, color: ColorRes.battleshipGrey),
          ),
          const Divider(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_sharp,
                size: 25,
                color: ColorRes.havelockBlue,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  data?.clinicAddress ?? '',
                  style: const TextStyle(
                      fontSize: 14,
                      color: ColorRes.battleshipGrey,
                      overflow: TextOverflow.ellipsis),
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              _portfolioCard(
                  title1: "${data?.experienceYear ?? 0}",
                  title2: S.current.years,
                  category: S.current.experience),
              const SizedBox(
                width: 10,
              ),
              _portfolioCard(
                  title1: NumberFormat.compactCurrency(decimalDigits: 0, name: '')
                      .format(data?.totalPatientsCured ?? 0),
                  title2: "",
                  category: S.current.happyPatients)
            ],
          )
        ],
      ),
    );
  }

  Widget _portfolioCard(
      {required String title1, required String title2, required String category}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 2,
        ),
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
                    color: ColorRes.charcoalGrey, fontFamily: FontRes.bold, fontSize: 17),
                children: [
                  TextSpan(
                      text: " $title2",
                      style: const TextStyle(
                          color: ColorRes.charcoalGrey, fontSize: 13, fontFamily: FontRes.regular))
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
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
