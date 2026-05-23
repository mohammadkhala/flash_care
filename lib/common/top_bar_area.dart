import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopBarArea extends StatelessWidget {
  final String title;
  final bool isMoreBtnVisible;
  final Function()? onVideoCallTap;
  final Function()? onBack;

  const TopBarArea({
    super.key,
    required this.title,
    this.isMoreBtnVisible = false,
    this.onVideoCallTap,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: ColorRes.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                    left: isRtl ? 0 : 12,
                    right: isRtl ? 12 : 0,
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
              style: const TextStyle(
                color: ColorRes.charcoalGrey,
                fontFamily: FontRes.bold,
                fontSize: 18,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Align(
              alignment: isRtl ? Alignment.centerLeft : Alignment.centerRight,
              child: Visibility(
                visible: isMoreBtnVisible,
                child: InkWell(
                  onTap: onVideoCallTap,
                  borderRadius: BorderRadius.circular(19),
                  child: Container(
                    height: 38,
                    width: 38,
                    margin: EdgeInsets.only(
                      right: isRtl ? 0 : 12,
                      left: isRtl ? 12 : 0,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF00897B), Color(0xFF00695C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.videocam_rounded,
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
