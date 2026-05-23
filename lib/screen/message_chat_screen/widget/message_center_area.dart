import 'package:doctor_flutter/common/chat_widget/chat_date_formate.dart';
import 'package:doctor_flutter/common/chat_widget/chat_image_card.dart';
import 'package:doctor_flutter/common/chat_widget/chat_msg_text_card.dart';
import 'package:doctor_flutter/common/chat_widget/chat_video_card.dart';
import 'package:doctor_flutter/common/common_fun.dart';
import 'package:doctor_flutter/model/chat/chat.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/firebase_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageCenterArea extends StatelessWidget {
  final ScrollController scrollController;
  final RxList<ChatMessage> chatList;
  final DoctorData? doctorData;
  final Function(ChatMessage? chatMessage) onLongPress;
  final List<String> timeStamp;

  const MessageCenterArea({super.key,
      required this.scrollController,
      required this.chatList,
      required this.doctorData,
      required this.onLongPress,
      required this.timeStamp});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(
        () => ListView.builder(
          controller: scrollController,
          itemCount: chatList.length,
          reverse: true,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            ChatMessage? chatData = chatList[index];
            return ChatMessageWidget(
              data: chatData,
              isMe: chatData.senderUser?.userIdentity ==
                  CommonFun.setDoctorId(doctorId: doctorData?.id),
              timeStamp: timeStamp,
              onLongPress: onLongPress,
            );
          },
        ),
      ),
    );
  }
}

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage data;
  final bool isMe;
  final List<String> timeStamp;
  final Function(ChatMessage) onLongPress;

  const ChatMessageWidget({
    super.key,
    required this.data,
    required this.isMe,
    required this.timeStamp,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    bool selected = timeStamp.contains('${data.id}');
    return GestureDetector(
      onLongPress: () => onLongPress(data),
      onTap: () => timeStamp.isNotEmpty ? onLongPress(data) : () {},
      child: Container(
        foregroundDecoration: BoxDecoration(
          color: selected ? ColorRes.iceberg.withValues(alpha: 0.5) : ColorRes.transparent,
        ),
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 2),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            data.msgType == FirebaseRes.text
                ? ChatMsgTextCard(
                    msg: data.msg ?? '',
                    cardColor:
                        isMe ? ColorRes.havelockBlue : ColorRes.whiteSmoke,
                    textColor: isMe ? ColorRes.white : ColorRes.davyGrey,
                  )
                : data.msgType == FirebaseRes.image
                    ? ChatImageCard(
                        imageUrl: data.image,
                        time: data.id,
                        msg: data.msg,
                        imageCardColor:
                            isMe ? ColorRes.havelockBlue : ColorRes.whiteSmoke,
                        margin: EdgeInsets.only(
                          left: isMe
                              ? MediaQuery.of(context).size.width / 2.3
                              : 0,
                          right: isMe
                              ? 0
                              : MediaQuery.of(context).size.width / 2.3,
                        ),
                        imageTextColor:
                            isMe ? ColorRes.white : ColorRes.davyGrey,
                      )
                    : ChatVideoCard(
                        imageUrl: data.image,
                        time: data.id,
                        msg: data.msg,
                        videoUrl: data.video,
                        margin: EdgeInsets.only(
                          left: isMe
                              ? MediaQuery.of(context).size.width / 2.3
                              : 0,
                          right: isMe
                              ? 0
                              : MediaQuery.of(context).size.width / 2.3,
                        ),
                        imageCardColor:
                            isMe ? ColorRes.havelockBlue : ColorRes.whiteSmoke,
                        imageTextColor:
                            isMe ? ColorRes.white : ColorRes.davyGrey,
                      ),
            ChatDateFormat(time: data.id ?? ''),
          ],
        ),
      ),
    );
  }
}
