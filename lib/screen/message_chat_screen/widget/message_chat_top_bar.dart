import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/confirmation_dialog.dart';
import 'package:patient_flutter/common/image_builder_custom.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/chat/chat.dart';
import 'package:patient_flutter/screen/message_chat_screen/message_chat_screen_controller.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

import 'bottom_selected_item_bar.dart';

class MessageChatTopBar extends StatelessWidget {
  final Conversation? conversation;
  final MessageChatScreenController controller;

  const MessageChatTopBar(
      {super.key, required this.conversation, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: ColorRes.whiteSmoke,
      padding: const EdgeInsets.all(10),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            AnimatedOpacity(
              opacity: controller.timeStamp.isEmpty ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 25,
                      color: ColorRes.davyGrey,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ImageBuilderCustom(conversation?.user?.image,
                      size: 55,
                      isDecorationVisible: true,
                      name: conversation?.user?.username),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conversation?.user?.username ?? S.current.unKnown,
                          style: MyTextStyle.montserratExtraBold(
                            size: 17,
                            color: ColorRes.davyGrey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          conversation?.user?.designation ?? '',
                          style: MyTextStyle.montserratMedium(
                              size: 13, color: ColorRes.havelockBlue),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              opacity: controller.timeStamp.isNotEmpty ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Visibility(
                visible: controller.timeStamp.isNotEmpty,
                child: BottomSelectedItemBar(
                  onBackTap: controller.onMsgDeleteBackTap,
                  selectedItemCount: controller.timeStamp.length,
                  onItemDelete: () {
                    Get.dialog(
                      ConfirmationDialog(
                        onPositiveTap: controller.onChatItemDelete,
                        title1: S.of(context).deleteMessage,
                        title2: S
                            .of(context)
                            .areYouSureYouWantToDeleteThisMessageOnce,
                        positiveText: S.current.delete,
                        aspectRatio: 1.5,
                      ),
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
