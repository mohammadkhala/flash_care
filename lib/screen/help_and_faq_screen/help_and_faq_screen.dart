import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/common/top_bar_area.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/help_and_faq_screen/help_and_faq_screen_controller.dart';
import 'package:patient_flutter/screen/help_and_faq_screen/widget/center_area.dart';
import 'package:patient_flutter/screen/help_and_faq_screen/widget/list_of_category.dart';

class HelpAndFaqScreen extends StatelessWidget {
  const HelpAndFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HelpAndFaqScreenController());
    return Scaffold(
      body: GetBuilder(
        init: controller,
        builder: (context) {
          return Column(
            children: [
              TopBarArea(title: S.current.helpAndFAQ),
              controller.isLoading
                  ? CustomUi.loaderWidget()
                  : Expanded(
                      child: Column(
                        children: [
                          ListOfCategory(
                              faqs: controller.faqs,
                              onCategoryChange: controller.onCategoryChange,
                              selectedCategory: controller.selectedCategory),
                          CenterArea(
                            faqs: controller.faqs[controller.selectedCategory].faqs ?? [],
                          ),
                        ],
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}
