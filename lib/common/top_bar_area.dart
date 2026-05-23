import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class TopBarArea extends StatelessWidget {
  final String title;
  final Function()? onQrCodeTap;
  final Function()? onBack;
  final bool isQrCodeVisible;
  final Widget? widget;

  const TopBarArea({
    super.key,
    required this.title,
    this.isQrCodeVisible = false,
    this.onQrCodeTap,
    this.onBack,
    this.widget,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: ColorRes.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SafeArea(
        bottom: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
              child: InkWell(
                onTap: onBack ?? () => Get.back(),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 38,
                  height: 38,
                  margin: EdgeInsets.only(
                    right: isRtl ? 12 : 0,
                    left: isRtl ? 0 : 12,
                  ),
                  decoration: BoxDecoration(
                    color: ColorRes.whiteSmoke,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: ColorRes.charcoalGrey,
                    size: 20,
                  ),
                ),
              ),
            ),
            Text(
              title,
              style: MyTextStyle.montserratBold(
                size: 18,
                color: ColorRes.charcoalGrey,
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: widget ??
                  Visibility(
                    visible: isQrCodeVisible,
                    child: InkWell(
                      onTap: onQrCodeTap,
                      borderRadius: BorderRadius.circular(19),
                      child: Container(
                        height: 38,
                        width: 38,
                        margin: EdgeInsets.only(
                          right: isRtl ? 0 : 12,
                          left: isRtl ? 12 : 0,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00897B), Color(0xFF00695C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(19),
                        ),
                        child: const Icon(
                          Icons.qr_code_2_rounded,
                          color: ColorRes.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
