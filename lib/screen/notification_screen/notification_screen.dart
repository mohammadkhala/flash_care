import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/common/top_bar_tab.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/screen/notification_screen/notification_screen_controller.dart';
import 'package:doctor_flutter/screen/notification_screen/widget/notification_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationScreenController());
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6FAF8),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'الإشعارات',
          style: TextStyle(
            fontFamily: 'ProductSans-Bold',
            fontSize: 17,
            color: Color(0xFF171D1B),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF171D1B), size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: GetBuilder(
        init: controller,
        builder: (context) {
          return controller.isLoading
              ? CustomUi.loaderWidget()
              : controller.notifications == null || controller.notifications!.isEmpty
                  ? CustomUi.noDataImage()
                  : ListView.builder(
                      controller: controller.notificationController,
                      itemCount: controller.notifications?.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) =>
                          NotificationCard(data: controller.notifications?[index]),
                    );
        },
      ),
    );
  }
}
