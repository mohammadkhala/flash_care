import 'package:doctor_flutter/common/common_fun.dart';
import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/common/image_builder_custom.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/chat/chat.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/screen/message_chat_screen/message_chat_screen.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:doctor_flutter/utils/style_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageCard extends StatelessWidget {
  final List<Conversation?> userList;
  final Function(Conversation? user) onLongPress;
  final DoctorData? doctorData;

  const MessageCard({super.key,
      required this.userList,
      required this.onLongPress,
      this.doctorData});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: userList.isEmpty
          ? CustomUi.noDataImage(message: S.current.noUser)
          : ListView.builder(
              itemCount: userList.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                Conversation? user = userList[index];
                return InkWell(
                  onTap: () {
                    Get.to(() => MessageChatScreen(
                        conversation: user, doctorData: doctorData));
                  },
                  onLongPress: () => onLongPress(user),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    decoration: const BoxDecoration(
                      color: ColorRes.whiteSmoke,
                    ),
                    child: Row(
                      children: [
                        ImageBuilderCustom(user?.user?.image,
                            size: 70, name: user?.user?.username),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.user?.username ?? S.current.unKnown,
                                style: const TextStyle(
                                    color: ColorRes.charcoalGrey,
                                    fontFamily: FontRes.extraBold,
                                    fontSize: 18,
                                    overflow: TextOverflow.ellipsis),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.lastMsg ?? '',
                                style: const TextStyle(
                                    color: ColorRes.battleshipGrey,
                                    fontSize: 14,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          children: [
                            Text(
                              CommonFun.timeAgo(
                                DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(user?.time ?? ''),
                                ),
                              ),
                              style: const TextStyle(
                                  fontFamily: FontRes.medium,
                                  fontSize: 12,
                                  color: ColorRes.silverChalice),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            user?.user?.msgCount == 0
                                ? const SizedBox(
                                    height: 25,
                                    width: 25,
                                  )
                                : Container(
                                    height: 25,
                                    width: 25,
                                    decoration: const BoxDecoration(
                                        gradient: StyleRes.linearGradient,
                                        shape: BoxShape.circle),
                                    alignment: Alignment.center,
                                    child: Text(
                                      user?.user?.msgCount.toString() ?? '',
                                      style: const TextStyle(
                                          fontFamily: FontRes.bold,
                                          fontSize: 12,
                                          color: ColorRes.white),
                                    ),
                                  )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
