import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/close_button_custom.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeSheet extends StatelessWidget {
  final int? appointmentId;

  const QrCodeSheet({super.key, this.appointmentId});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          margin: EdgeInsets.only(top: AppBar().preferredSize.height * 4),
          decoration: const BoxDecoration(
            color: ColorRes.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          padding: const EdgeInsets.only(left: 15, right: 15, top: 25, bottom: 10),
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
                          S.current.showThisQRAtClinic,
                          style: MyTextStyle.montserratExtraBold(size: 20, color: ColorRes.charcoalGrey),
                        ),
                        Text(
                          S.current.offerThisQRAtClinicShop,
                          style: MyTextStyle.montserratLight(size: 16, color: ColorRes.davyGrey),
                        ),
                      ],
                    ),
                  ),
                  const CloseButtonCustom()
                ],
              ),
              SizedBox(
                height: AppBar().preferredSize.height,
              ),
              QrImageView(
                data: "$appointmentId",
                version: QrVersions.auto,
                size: Get.width / 2,
                errorCorrectionLevel: 2,
                gapless: false,
              ),
              SizedBox(
                height: AppBar().preferredSize.height,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
