import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/chat_widget/chat_audio_card.dart';
import 'package:patient_flutter/common/chat_widget/chat_date_formate.dart';
import 'package:patient_flutter/common/chat_widget/chat_file_card.dart';
import 'package:patient_flutter/common/chat_widget/chat_image_card.dart';
import 'package:patient_flutter/common/chat_widget/chat_video_card.dart';
import 'package:patient_flutter/common/chat_widget/msg_text_card.dart';
import 'package:patient_flutter/model/chat/appointment_chat.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/screen/appointment_chat_screen/widget/video_call_card.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/firebase_res.dart';

class CenterAreaChat extends StatelessWidget {
  final ScrollController scrollController;
  final List<AppointmentChat> chatData;
  final UserData? user;
  final Function(AppointmentChat data) onJoinMeeting;

  const CenterAreaChat(
      {super.key,
      required this.scrollController,
      required this.chatData,
      this.user,
      required this.onJoinMeeting});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(10),
        child: ScrollConfiguration(
          behavior: MyBehavior(),
          child: ListView.builder(
            primary: false,
            shrinkWrap: true,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            itemCount: chatData.length,
            padding: EdgeInsets.zero,
            reverse: true,
            itemBuilder: (context, index) {
              AppointmentChat data = chatData[index];
              return data.senderUser?.userId == user?.id
                  ? _yourMsg(data)
                  : _otherMsg(
                      data,
                    );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMsg(AppointmentChat data, bool isMine) {
    final edgeInset = isMine
        ? EdgeInsets.only(left: Get.width / 2.3)
        : EdgeInsets.only(right: Get.width / 2.3);
    final cardColor = isMine ? ColorRes.whiteSmoke : ColorRes.havelockBlue;
    final textColor = isMine ? ColorRes.davyGrey : ColorRes.white;

    switch (data.msgType) {
      case FirebaseRes.text:
        return MsgTextCard(
            appointmentData: data, cardColor: cardColor, textColor: textColor);
      case FirebaseRes.image:
        return ChatImageCard(
            imageUrl: data.image,
            time: data.id,
            imageCardColor: cardColor,
            margin: edgeInset,
            msg: data.msg,
            imageTextColor: textColor);
      case FirebaseRes.video:
        return ChatVideoCard(
            imageUrl: data.image,
            time: data.id,
            margin: edgeInset,
            msg: data.msg,
            videoUrl: data.video,
            imageCardColor: cardColor,
            imageTextColor: textColor);
      case FirebaseRes.audio:
        return Container(
          margin: edgeInset,
          child: ChatAudioCard(
              audioUrl: data.audio, time: data.id, cardColor: cardColor),
        );
      case FirebaseRes.file:
        return Container(
          margin: edgeInset,
          child: ChatFileCard(
              fileUrl: data.file,
              fileName: data.fileName,
              time: data.id,
              cardColor: cardColor),
        );
      default:
        return VideoCallCard(data: data, onJoinMeeting: onJoinMeeting);
    }
  }

  _yourMsg(AppointmentChat data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildMsg(data, true),
        ChatDateFormat(time: data.id ?? ''),
      ],
    );
  }

  _otherMsg(AppointmentChat data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMsg(data, false),
        ChatDateFormat(time: data.id ?? ''),
      ],
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
