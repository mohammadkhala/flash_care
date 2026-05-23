import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/close_button_custom.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/appointment/coupon.dart';
import 'package:patient_flutter/screen/coupon_sheet/coupon_sheet_controller.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';
import 'package:patient_flutter/utils/update_res.dart';

class CouponSheet extends StatelessWidget {
  final Function(CouponData? coupon) onCouponTap;

  const CouponSheet({
    super.key,
    required this.onCouponTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CouponSheetController());
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 25, bottom: 10),
      margin: EdgeInsets.only(top: AppBar().preferredSize.height * 2),
      decoration: const BoxDecoration(
          color: ColorRes.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.current.applyCoupon,
                      style: MyTextStyle.montserratExtraBold(
                          size: 20, color: ColorRes.charcoalGrey),
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Text(
                      S.current.tapOnACouponEtc,
                      style: MyTextStyle.montserratLight(
                          size: 16, color: ColorRes.davyGrey),
                    ),
                  ],
                ),
              ),
              const CloseButtonCustom()
            ],
          ),
          Expanded(
            child: GetBuilder(
              init: controller,
              builder: (context) {
                return controller.isLoading
                    ? CustomUi.loaderWidget()
                    : ListView.builder(
                        itemCount: controller.coupons?.length,
                        itemBuilder: (context, index) {
                          CouponData? coupons = controller.coupons?[index];
                          return InkWell(
                            onTap: () => onCouponTap(coupons),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  DottedBorder(
                                    options: RoundedRectDottedBorderOptions(
                                        color: ColorRes.darkSkyBlue,
                                        radius: const Radius.circular(7),
                                        strokeWidth: 2,
                                        dashPattern: const [5, 3]),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 30, vertical: 15),
                                      decoration: BoxDecoration(
                                          color: ColorRes.snowDrift,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  (coupons?.heading ?? '')
                                                      .toUpperCase(),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: MyTextStyle
                                                      .montserratBold(
                                                          size: 17,
                                                          color: ColorRes
                                                              .davyGrey),
                                                ),
                                              ),
                                              Text(
                                                (coupons?.coupon ?? '')
                                                    .toUpperCase(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    MyTextStyle.montserratBold(
                                                        size: 19,
                                                        color:
                                                            ColorRes.tuftsBlue),
                                              )
                                            ],
                                          ),
                                          Text(
                                            '${S.current.max} $dollar${coupons?.maxDiscountAmount.toString() ?? ''}'
                                                .toUpperCase(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: MyTextStyle.montserratLight(
                                                size: 13,
                                                color: ColorRes.battleshipGrey),
                                          ),
                                          const SizedBox(
                                            height: 7,
                                          ),
                                          Text(
                                            coupons?.description ?? '',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: MyTextStyle.montserratMedium(
                                              size: 14,
                                              color: ColorRes.battleshipGrey,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: -15,
                                    child: DottedBorder(
                                      options: CircularDottedBorderOptions(
                                          strokeWidth: 1,
                                          dashPattern: const [5, 2],
                                          color: ColorRes.darkSkyBlue),
                                      child: Container(
                                        height: 50,
                                        width: 30,
                                        decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: -15,
                                    child: DottedBorder(
                                      options: CircularDottedBorderOptions(
                                          strokeWidth: 1,
                                          dashPattern: const [5, 2],
                                          color: ColorRes.darkSkyBlue),
                                      child: Container(
                                        height: 50,
                                        width: 30,
                                        decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
              },
            ),
          )
        ],
      ),
    );
  }
}
