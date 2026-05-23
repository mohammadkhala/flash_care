import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/chat/appointment_chat.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class VideoCallCard extends StatelessWidget {
  final AppointmentChat data;
  final Function(AppointmentChat data) onJoinMeeting;

  const VideoCallCard({
    super.key,
    required this.data,
    required this.onJoinMeeting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: Get.width / 1.4,
      ),
      decoration: BoxDecoration(
        color: ColorRes.whiteSmoke,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: S.current.video,
                    style: MyTextStyle.montserratExtraBold(size: 14, color: ColorRes.tuftsBlue),
                    children: [
                      TextSpan(
                          text: " ${S.current.consultation}",
                          style: MyTextStyle.montserratMedium(
                            color: ColorRes.tuftsBlue,
                            size: 13,
                          ).copyWith(letterSpacing: 0.5)),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 7,
                ),
                Text(
                  '${data.senderUser?.name} ${S.of(context).isAskingYouToJoinEtc} ',
                  style: MyTextStyle.montserratRegular(size: 14, color: ColorRes.davyGrey),
                ),
                const SizedBox(
                  height: 7,
                ),
                Text(
                  DateFormat('dd MMM, yyyy - h:mm a', 'en').format(
                      DateTime.fromMillisecondsSinceEpoch(int.parse(data.videoCall?.time ?? ''))
                          .toLocal()),
                  style: MyTextStyle.montserratSemiBold(size: 13, color: ColorRes.tuftsBlue),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => onJoinMeeting(data),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: data.videoCall?.isStarted == true
                    ? ColorRes.davyGrey
                    : ColorRes.davyGrey.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(15),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                (data.videoCall?.isStarted == true ? S.current.joinMeeting : S.current.endMeeting)
                    .toUpperCase(),
                style: MyTextStyle.montserratSemiBold(size: 13, color: ColorRes.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
