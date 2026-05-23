import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/text_button_custom.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/utils/asset_res.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class TransactionCompleteSheet extends StatelessWidget {
  const TransactionCompleteSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: ColorRes.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          margin: EdgeInsets.only(top: AppBar().preferredSize.height * 2),
          child: Column(
            children: [
              Container(
                height: Get.height / 3,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ColorRes.havelockBlue.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: Column(
                  children: [
                    const Spacer(),
                    Text(
                      S.current.transactionSuccessful,
                      style: MyTextStyle.montserratBold(size: 17, color: ColorRes.havelockBlue),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Image.asset(
                      AssetRes.icRoundVerifiedBig,
                      width: Get.width / 4,
                      height: Get.width / 4,
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Text(
                S.current.fundsHaveBeenAddedEtc,
                textAlign: TextAlign.center,
                style: MyTextStyle.montserratBold(size: 18, color: ColorRes.davyGrey),
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                S.current.nowYouCanBookAppointmentsEtc,
                textAlign: TextAlign.center,
                style: MyTextStyle.montserratRegular(color: ColorRes.battleshipGrey),
              ),
              const SizedBox(
                height: 80,
              ),
              SafeArea(
                top: false,
                child: TextButtonCustom(
                    onPressed: () {
                      Get.back();
                    },
                    title: S.current.continueText,
                    titleColor: ColorRes.white,
                    backgroundColor: ColorRes.darkSkyBlue),
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        )
      ],
    );
  }
}
