import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/common/dashboard_top_bar_title.dart';
import 'package:patient_flutter/common/top_bar_area.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/home/home.dart';
import 'package:patient_flutter/screen/specialists_detail_screen/specialists_detail_screen.dart';
import 'package:patient_flutter/screen/specialists_screen/specialists_screen_controller.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class SpecialistsScreen extends StatelessWidget {
  final int screenType;

  const SpecialistsScreen({super.key, required this.screenType});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SpecialistsScreenController());
    return Scaffold(
      body: Column(
        children: [
          screenType == 0
              ? DashboardTopBarTitle(title: S.current.specialists)
              : TopBarArea(title: S.current.specialists),
          GetBuilder(
            init: controller,
            builder: (_) {
              return Expanded(
                child: controller.isLoading && controller.categories.isEmpty
                    ? CustomUi.loaderWidget()
                    : controller.categories.isEmpty
                        ? CustomUi.noData()
                        : GridView.builder(
                            itemCount: controller.categories.length,
                            padding: const EdgeInsets.all(10),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 1.7),
                            itemBuilder: (context, index) {
                              Categories category = controller.categories[index];
                              return InkWell(
                                onTap: () {
                                  Get.to(() => const SpecialistsDetailScreen(),
                                      arguments: controller.categories[index]);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: ColorRes.havelockBlue.withValues(alpha: 0.1)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: '${ConstRes.itemBaseURL}${category.image ?? ' '}',
                                        width: 30,
                                        height: 30,
                                        color: ColorRes.havelockBlue,
                                        errorWidget: (context, url, error) {
                                          return Container();
                                        },
                                      ),
                                      Text(
                                        category.title?.capitalize ?? '',
                                        style: MyTextStyle.montserratSemiBold(
                                            size: 15, color: ColorRes.havelockBlue),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              );
            },
          ),
        ],
      ),
    );
  }
}
