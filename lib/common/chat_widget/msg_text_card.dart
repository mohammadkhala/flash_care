import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/model/chat/appointment_chat.dart';
import 'package:patient_flutter/model/chat/chat.dart';

class MsgTextCard extends StatelessWidget {
  final ChatMessage? chatData;
  final AppointmentChat? appointmentData;
  final Color cardColor;
  final Color textColor;

  const MsgTextCard(
      {super.key,
      required this.cardColor,
      required this.textColor,
      this.chatData,
      this.appointmentData});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: Get.width / 1.3,
      ),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: appointmentData != null
          ? Text(
              appointmentData?.msg ?? '',
              style: TextStyle(color: textColor, fontSize: 14),
            )
          : chatData != null && chatData?.senderUser?.userid == 0
              ? Markdown(
                  data: chatData?.msg ?? '',
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                )
              : Text(
                  chatData?.msg ?? '',
                  style: TextStyle(color: textColor, fontSize: 14),
                ),
    );
  }
}
