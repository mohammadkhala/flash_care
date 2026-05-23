import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jumping_dot/jumping_dot.dart';
import 'package:patient_flutter/common/chat_widget/chat_bottom_text_filed.dart';
import 'package:patient_flutter/common/fancy_button.dart';
import 'package:patient_flutter/model/chat/chat.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/screen/message_chat_screen/message_chat_screen_controller.dart';
import 'package:patient_flutter/screen/message_chat_screen/widget/message_center_area.dart';
import 'package:patient_flutter/utils/color_res.dart';

import 'widget/message_chat_top_bar.dart';

class MessageChatScreen extends StatelessWidget {
  final Conversation? conversation;
  final UserData? userData;

  const MessageChatScreen(
      {super.key, required this.conversation, required this.userData});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MessageChatScreenController(
        conversation: conversation, userData: userData));
    return Scaffold(
      backgroundColor: ColorRes.white,
      body: GetBuilder(
          init: controller,
          tag: '${DateTime.now().millisecondsSinceEpoch}',
          builder: (controller) {
            return GestureDetector(
              onTap: controller.allScreenTap,
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      MessageChatTopBar(
                          conversation: controller.conversation,
                          controller: controller),
                      MessageCenterArea(
                        scrollController: controller.scrollController,
                        chatData: controller.chatList,
                        userData: controller.userData,
                        onLongPress: controller.onLongPress,
                        timeStamp: controller.timeStamp,
                      ),
                      Obx(
                        () => !controller.isGenerateResponse.value
                            ? SizedBox()
                            : Container(
                                width: 100,
                                height: 40,
                                margin: EdgeInsets.only(
                                    left: 10, right: 10, bottom: 10),
                                decoration: BoxDecoration(
                                  color: ColorRes.whiteSmoke,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: JumpingDots(
                                  color: ColorRes.silverChalice,
                                  radius: 8,
                                  numberOfDots: 3,
                                  animationDuration:
                                      Duration(milliseconds: 300),
                                ),
                              ),
                      ),
                      ChatBottomTextFiled(
                        msgController: controller.msgController,
                        onSendTap: controller.onSendBtnTap,
                        onTextFiledTap: controller.onTextFiledTap,
                      ),
                    ],
                  ),
                  Positioned(
                    right: Directionality.of(context) == TextDirection.rtl
                        ? null
                        : 6,
                    bottom: 4,
                    left: Directionality.of(context) == TextDirection.rtl
                        ? 6
                        : null,
                    child: SafeArea(
                      top: false,
                      child: FancyButton(
                        key: controller.key,
                        onCameraTap: () =>
                            controller.onImageTap(source: ImageSource.camera),
                        onGalleryTap: () =>
                            controller.onImageTap(source: ImageSource.gallery),
                        onVideoTap: controller.onVideoTap,
                        isOpen: controller.isOpen,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
