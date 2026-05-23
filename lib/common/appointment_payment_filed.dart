import 'package:flutter/material.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/font_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';
import 'package:patient_flutter/utils/update_res.dart';

class AppointmentPaymentFiled extends StatelessWidget {
  final String title;
  final num amount;
  final String? couponCode;
  final bool isCouponCodeVisible;
  final bool isCloseBtnVisible;
  final VoidCallback onCancelCoupon;
  final Color color;
  final Color titleColor;
  final Color discountColor;

  const AppointmentPaymentFiled(
      {super.key,
      required this.title,
      required this.amount,
      this.couponCode,
      this.isCouponCodeVisible = false,
      this.isCloseBtnVisible = false,
      required this.onCancelCoupon,
      this.color = ColorRes.aquaHaze,
      this.titleColor = ColorRes.davyGrey,
      this.discountColor = ColorRes.tuftsBlue});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: MyTextStyle.montserratMedium(color: titleColor),
              ),
              const Spacer(),
              Text(
                '${isCouponCodeVisible == true ? '-' : ''}$dollar$amount',
                style: TextStyle(
                    fontFamily: FontRes.bold,
                    fontSize: 17,
                    color: discountColor),
              )
            ],
          ),
          Visibility(
            visible: isCouponCodeVisible,
            child: const SizedBox(
              height: 10,
            ),
          ),
          Visibility(
            visible: isCouponCodeVisible,
            child: FittedBox(
              child: Container(
                decoration: BoxDecoration(
                    color: ColorRes.dawnPink,
                    borderRadius: BorderRadius.circular(6)),
                child: Row(
                  children: [
                    Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      child: Text(
                        '$couponCode'.toUpperCase(),
                        style: const TextStyle(
                            color: ColorRes.tuftsBlue,
                            fontFamily: FontRes.bold,
                            fontSize: 13),
                      ),
                    ),
                    Visibility(
                      visible: isCloseBtnVisible,
                      child: InkWell(
                        onTap: onCancelCoupon,
                        child: Container(
                          height: 30,
                          width: 28,
                          decoration: const BoxDecoration(
                              color: ColorRes.lightGrey,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(6),
                                  bottomRight: Radius.circular(6))),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: ColorRes.davyGrey,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
