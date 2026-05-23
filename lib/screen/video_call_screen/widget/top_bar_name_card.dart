import 'package:flutter/material.dart';
import 'package:patient_flutter/screen/video_call_screen/video_call_screen_controller.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class TopBarNameCard extends StatelessWidget {
  final VideoCallScreenController controller;

  const TopBarNameCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
          color: ColorRes.darkJungleGreen.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Row(
        children: [
          InkWell(
            onTap: controller.leave,
            child: const Icon(
              Icons.arrow_back,
              color: ColorRes.white,
              size: 30,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                controller.appointmentChat.senderUser?.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: MyTextStyle.montserratExtraBold(
                  size: 17,
                  color: ColorRes.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
