import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:patient_flutter/common/animate_expansion.dart';
import 'package:patient_flutter/common/appointment_payment_filed.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/appointment/fetch_appointment.dart';
import 'package:patient_flutter/model/custom/order_summary.dart';
import 'package:patient_flutter/model/global/taxes.dart';
import 'package:patient_flutter/screen/confirm_booking_screen/widget/booking_top_card.dart';
import 'package:patient_flutter/utils/asset_res.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/extention.dart';
import 'package:patient_flutter/utils/my_text_style.dart';
import 'package:patient_flutter/utils/update_res.dart';

class AppointmentBillCard extends StatelessWidget {
  final AppointmentData? appointmentData;
  final Function(bool value) onExpandTap;
  final bool isExpand;

  const AppointmentBillCard(
      {super.key,
      required this.appointmentData,
      required this.isExpand,
      required this.onExpandTap});

  @override
  Widget build(BuildContext context) {
    OrderSummary orderSummary =
        OrderSummary.fromJson(jsonDecode('${appointmentData?.orderSummary}'));
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: ColorRes.snowDrift,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              BookingTopCard(
                title: S.current.date,
                value: CustomUi.dateFormat(appointmentData?.date),
              ),
              BookingTopCard(
                title: S.current.time,
                value:
                    CustomUi.convert24HoursInto12Hours(appointmentData?.time),
              ),
              BookingTopCard(
                title: S.current.type,
                value: appointmentData?.type == 0
                    ? S.current.online
                    : S.current.clinic,
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          AnimatedExpansion(
            expand: appointmentData?.status == 2 ? (isExpand) : true,
            child: Column(
              children: [
                AppointmentPaymentFiled(
                    onCancelCoupon: () {},
                    title: S.current.consultationCharge,
                    amount: orderSummary.serviceAmount ?? 0),
                const SizedBox(
                  height: 3,
                ),
                Visibility(
                  visible: orderSummary.couponApply == 1,
                  child: AppointmentPaymentFiled(
                      onCancelCoupon: () {},
                      title: S.current.couponDiscount,
                      amount: orderSummary.discountAmount ?? 0,
                      isCouponCodeVisible: true,
                      couponCode: orderSummary.coupon?.coupon),
                ),
                const SizedBox(
                  height: 3,
                ),
                AppointmentPaymentFiled(
                    onCancelCoupon: () {},
                    title: S.current.subTotal,
                    amount: orderSummary.subtotal ?? 0),
                const SizedBox(
                  height: 3,
                ),
                Visibility(
                  visible: orderSummary.taxes != null,
                  child: ListView.builder(
                    primary: false,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: orderSummary.taxes?.length,
                    itemBuilder: (context, index) {
                      Taxes? tax = orderSummary.taxes?[index];
                      return Container(
                        color: ColorRes.aquaHaze,
                        margin: const EdgeInsets.only(bottom: 5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: '${tax?.taxTitle} ',
                                    style: MyTextStyle.montserratMedium(
                                        color: ColorRes.davyGrey),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: tax?.type == 0
                                            ? '(${tax?.value ?? ''}$percentage)'
                                            : '',
                                        style: MyTextStyle.montserratBold(
                                            color: ColorRes.tuftsBlue,
                                            size: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '$dollar${(double.parse('${tax?.taxAmount ?? '0'}')).numFormat}',
                                  style: MyTextStyle.montserratBold(
                                      size: 17, color: ColorRes.tuftsBlue),
                                )
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                AppointmentPaymentFiled(
                    onCancelCoupon: () {},
                    title: S.current.payableAmount,
                    amount: orderSummary.payableAmount ?? 0),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
          Visibility(
            visible: appointmentData?.status == 2,
            child: Theme(
              data: ThemeData(
                dividerColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(15),
                ),
                child: ListTileTheme(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 0,
                  ),
                  child: ExpansionTile(
                    trailing: const SizedBox(width: 30),
                    expandedAlignment: Alignment.center,
                    maintainState: false,
                    onExpansionChanged: onExpandTap,
                    title: Center(
                      child: Image.asset(
                        AssetRes.icMore,
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                      ),
                    ),
                    tilePadding: EdgeInsets.zero,
                    collapsedBackgroundColor: ColorRes.whiteSmoke,
                    iconColor: ColorRes.davyGrey,
                    childrenPadding: EdgeInsets.zero,
                    leading: const SizedBox(),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
