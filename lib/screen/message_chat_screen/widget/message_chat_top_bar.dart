import 'package:doctor_flutter/common/confirmation_dialog.dart';
import 'package:doctor_flutter/common/image_builder_custom.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/chat/chat.dart';
import 'package:doctor_flutter/screen/message_chat_screen/message_chat_screen_controller.dart';
import 'package:doctor_flutter/screen/message_chat_screen/widget/bottom_selected_item_bar.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageChatTopBar extends StatelessWidget {
  final Conversation? conversation;
  final MessageChatScreenController controller;

  const MessageChatTopBar(
      {super.key, required this.conversation, required this.controller});

  @override
  Widget build(BuildContext context) {
    ChatUser? user = conversation?.user;
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
                      Icons.arrow_back_rounded,
                      size: 25,
                      color: ColorRes.davyGrey,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: ColorRes.tuftsBlue, width: 2.5),
                      ),
                      child: ImageBuilderCustom(user?.image,
                          size: 70, name: user?.username)),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.username ?? S.current.unKnown,
                          style: const TextStyle(
                            fontFamily: FontRes.extraBold,
                            color: ColorRes.davyGrey,
                            fontSize: 17,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          ((user?.age ?? '0') == '0')
                              ? user?.gender == 'Male'
                                  ? S.current.male
                                  : S.current.feMale
                              : "${user?.age} ${S.current.years} : ${user?.gender == 'Male' ? S.current.male : S.current.feMale}",
                          style: const TextStyle(
                            fontFamily: FontRes.medium,
                            color: ColorRes.battleshipGrey,
                            fontSize: 13,
                          ),
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
                        aspectRatio: 1.7,
                        onPositiveTap: controller.onChatItemDelete,
                        title1: S.of(context).deleteMessage,
                        title2: S
                            .of(context)
                            .areYouSureYouWantToDeleteThisMessageOnce,
                        positiveText: S.current.delete,
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

