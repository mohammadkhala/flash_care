import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/common/top_bar_area.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/message_screen/message_screen_controller.dart';
import 'package:patient_flutter/screen/message_screen/widget/message_card.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MessageScreenController());
    return Scaffold(
      body: Column(
        children: [
          TopBarArea(title: S.current.messages),
          const SizedBox(height: 3),
          Expanded(
            child: Obx(
              () => controller.isLoading.value && controller.userList.isEmpty
                  ? CustomUi.loaderWidget()
                  : controller.userList.isEmpty
                      ? CustomUi.noDataImage(message: S.of(context).noUsers)
                      : ListView.builder(
                          itemCount: controller.userList.length,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            return MessageCard(
                                conversation: controller.userList[index],
                                userData: controller.userData,
                                onLongPress: controller.onLongPress);
                          },
                        ),
            ),
          )
        ],
      ),
    );
  }
}
