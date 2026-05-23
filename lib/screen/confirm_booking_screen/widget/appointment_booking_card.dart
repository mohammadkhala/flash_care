import 'package:flutter/material.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/appointment/coupon.dart';
import 'package:patient_flutter/model/custom/categories.dart';
import 'package:patient_flutter/screen/confirm_booking_screen/confirm_booking_screen_controller.dart';
import 'package:patient_flutter/screen/confirm_booking_screen/widget/booking_top_card.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';
import 'package:patient_flutter/utils/update_res.dart';

class AppointmentBookingCard extends StatelessWidget {
  final bool isApplyCouponVisible;
  final AppointmentDetail? detail;
  final List<CouponData>? coupons;
  final ConfirmBookingScreenController? controller;

  const AppointmentBookingCard(
      {super.key,
      this.isApplyCouponVisible = true,
      this.coupons,
      this.detail,
      this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: ColorRes.snowDrift,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const SizedBox(height: 15),
          // Date / Time / Type row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              BookingTopCard(
                  title: S.current.date,
                  value: CustomUi.dateFormat(detail?.date)),
              BookingTopCard(
                  title: S.current.time,
                  value: CustomUi.convert24HoursInto12Hours(detail?.time)),
              BookingTopCard(
                title: S.current.type,
                value: detail?.type == 0 ? S.current.online : S.current.clinic,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Consultation fee row
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: ColorRes.aquaHaze,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.current.consultationCharge,
                  style: MyTextStyle.montserratMedium(
                      size: 14, color: ColorRes.davyGrey),
                ),
                Text(
                  '$dollar${detail?.serviceAmount ?? 0}',
                  style: MyTextStyle.montserratBold(
                      size: 15, color: ColorRes.tuftsBlue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Cash-only banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              border: Border.all(color: ColorRes.fadedOrange, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.payments_outlined,
                    color: ColorRes.fadedOrange, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.current.cashOnly,
                        style: MyTextStyle.montserratSemiBold(
                            size: 14, color: ColorRes.fadedOrange),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        S.current.cashPaymentNote,
                        style: MyTextStyle.montserratRegular(
                            size: 12, color: ColorRes.smokeyGrey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
