import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:patient_flutter/common/chat_widget/chat_bottom_text_filed.dart';
import 'package:patient_flutter/common/fancy_button.dart';
import 'package:patient_flutter/common/top_bar_area.dart';
import 'package:patient_flutter/screen/appointment_chat_screen/appointment_chat_screen_controller.dart';
import 'package:patient_flutter/screen/appointment_chat_screen/widget/appointment_detail_list.dart';
import 'package:patient_flutter/screen/appointment_chat_screen/widget/center_area_chat.dart';
import 'package:patient_flutter/utils/color_res.dart';

class AppointmentChatScreen extends StatelessWidget {
  const AppointmentChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AppointmentChatScreenController());
    return Scaffold(
      backgroundColor: ColorRes.white,
      body: GestureDetector(
        onTap: controller.allScreenTap,
        child: Stack(
          children: [
            Column(
              children: [
                TopBarArea(
                  title: controller.appointmentData?.appointmentNumber ?? '',
                ),
                const SizedBox(
                  height: 5,
                ),
                AppointmentDetailList(
                  appointmentData: controller.appointmentData,
                ),
                GetBuilder(
                  init: controller,
                  builder: (context) {
                    return CenterAreaChat(
                      scrollController: controller.scrollController,
                      chatData: controller.chatData,
                      user: controller.appointmentData?.user,
                      onJoinMeeting: controller.onJoinMeeting,
                    );
                  },
                ),
                ChatBottomTextFiled(
                  onSendTap: controller.onSendTextMsg,
                  onTextFiledTap: controller.onTextFiledTap,
                  msgController: controller.msgController,
                )
              ],
            ),
            Positioned(
              right: Directionality.of(context) == TextDirection.rtl ? null : 6,
              bottom: 3,
              left: Directionality.of(context) == TextDirection.rtl ? 6 : null,
              child: SafeArea(
                top: false,
                child: GetBuilder(
                  init: controller,
                  builder: (context) {
                    return FancyButton(
                      key: controller.key,
                      onCameraTap: () => controller.onImageTap(source: ImageSource.camera),
                      onGalleryTap: () => controller.onImageTap(source: ImageSource.gallery),
                      onVideoTap: controller.onVideoTap,
                      onFileTap: controller.onFileTap,
                      onAudioTap: controller.isRecording
                          ? controller.onStopRecording
                          : controller.onStartRecording,
                      isOpen: controller.isOpen,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
