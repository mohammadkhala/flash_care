import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/chat_widget/chat_date_formate.dart';
import 'package:patient_flutter/common/chat_widget/chat_image_card.dart';
import 'package:patient_flutter/common/chat_widget/chat_video_card.dart';
import 'package:patient_flutter/common/chat_widget/msg_text_card.dart';
import 'package:patient_flutter/common/common_fun.dart';
import 'package:patient_flutter/model/chat/chat.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/firebase_res.dart';

class MessageCenterArea extends StatelessWidget {
  final ScrollController scrollController;
  final RxList<ChatMessage> chatData;
  final UserData? userData;
  final Function(ChatMessage? chatMessage) onLongPress;
  final List<String> timeStamp;

  const MessageCenterArea(
      {super.key,
      required this.scrollController,
      required this.chatData,
      required this.userData,
      required this.onLongPress,
      required this.timeStamp});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(
        () => ListView.builder(
          controller: scrollController,
          itemCount: chatData.length,
          reverse: true,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            ChatMessage? data = chatData[index];
            return _yourMsg(data,
                data.senderUser?.userIdentity == CommonFun.setPatientId(patientId: userData?.id));
          },
        ),
      ),
    );
  }

  _yourMsg(ChatMessage data, bool isMe) {
    bool selected = timeStamp.contains('${data.id}');
    return GestureDetector(
      onLongPress: () {
        onLongPress(data);
      },
      onTap: () {
        timeStamp.isNotEmpty ? onLongPress(data) : () {};
      },
      child: Container(
        foregroundDecoration: BoxDecoration(
            color: selected ? ColorRes.iceberg.withValues(alpha: 0.5) : ColorRes.transparent),
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 2),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            data.msgType == FirebaseRes.text
                ? MsgTextCard(
                    chatData: data,
                    cardColor: isMe ? ColorRes.havelockBlue : ColorRes.whiteSmoke,
                    textColor: isMe ? ColorRes.white : ColorRes.davyGrey)
                : data.msgType == FirebaseRes.image
                    ? ChatImageCard(
                        imageUrl: data.image,
                        time: data.id,
                        msg: data.msg,
                        imageCardColor: isMe ? ColorRes.havelockBlue : ColorRes.whiteSmoke,
                        margin: EdgeInsets.only(
                            left: isMe ? Get.width / 2.3 : 0, right: isMe ? 0 : Get.width / 2.3),
                        imageTextColor: isMe ? ColorRes.white : ColorRes.davyGrey)
                    : ChatVideoCard(
                        imageUrl: data.image,
                        time: data.id,
                        msg: data.msg,
                        videoUrl: data.video,
                        margin: EdgeInsets.only(
                            left: isMe ? Get.width / 2.3 : 0, right: isMe ? 0 : Get.width / 2.3),
                        imageCardColor: isMe ? ColorRes.havelockBlue : ColorRes.whiteSmoke,
                        imageTextColor: isMe ? ColorRes.white : ColorRes.davyGrey),
            ChatDateFormat(time: data.id ?? '')
          ],
        ),
      ),
    );
  }
}
