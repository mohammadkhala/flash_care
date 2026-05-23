import 'package:doctor_flutter/common/chat_widget/chat_bottom_text_filed.dart';
import 'package:doctor_flutter/common/fancy_button.dart';
import 'package:doctor_flutter/model/chat/chat.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/screen/message_chat_screen/message_chat_screen_controller.dart';
import 'package:doctor_flutter/screen/message_chat_screen/widget/message_center_area.dart';
import 'package:doctor_flutter/screen/message_chat_screen/widget/message_chat_top_bar.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class MessageChatScreen extends StatelessWidget {
  final Conversation? conversation;
  final DoctorData? doctorData;

  const MessageChatScreen(
      {super.key, required this.conversation, this.doctorData});

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.put(MessageChatScreenController(conversation, doctorData));
    return Scaffold(
      backgroundColor: ColorRes.white,
      body: GestureDetector(
        onTap: controller.allScreenTap,
        child: Stack(
          children: [
            Column(
              children: [
                GetBuilder(
                  init: controller,
                  builder: (controller) => MessageChatTopBar(
                      conversation: controller.conversationUser,
                      controller: controller),
                ),
                MessageCenterArea(
                  scrollController: controller.scrollController,
                  chatList: controller.chatList,
                  doctorData: controller.doctorData,
                  onLongPress: controller.onLongPress,
                  timeStamp: controller.timeStamp,
                ),
                ChatBottomTextFiled(
                    msgController: controller.msgController,
                    onSendTap: controller.onSendBtnTap,
                    onTextFiledTap: controller.onTextFiledTap,
                    msgFocusNode: controller.msgFocusNode),
              ],
            ),
            Positioned(
              right: Directionality.of(context) == TextDirection.rtl ? null : 6,
              bottom: 3,
              left: Directionality.of(context) == TextDirection.rtl ? 6 : null,
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
                  msgFocusNode: controller.msgFocusNode,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
