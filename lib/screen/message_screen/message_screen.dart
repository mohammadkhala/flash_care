import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/common/top_bar_area.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/screen/message_screen/message_screen_controller.dart';
import 'package:doctor_flutter/screen/message_screen/widget/message_card.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MessageScreenController());
    return Scaffold(
      backgroundColor: ColorRes.white,
      body: Column(
        children: [
          TopBarArea(title: S.current.message),
          const SizedBox(height: 5),
          GetBuilder(
            init: controller,
            builder: (context) {
              return controller.isLoading
                  ? Expanded(child: CustomUi.loaderWidget())
                  : MessageCard(
                      userList: controller.userList,
                      onLongPress: controller.onLongPress,
                      doctorData: controller.doctorData);
            },
          ),
        ],
      ),
    );
  }
}
