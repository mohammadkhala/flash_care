import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/common/top_bar_area.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/wallet/withdraw_request.dart';
import 'package:patient_flutter/screen/withdraw_history_screen/withdraw_history_screen_controller.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/extention.dart';
import 'package:patient_flutter/utils/my_text_style.dart';
import 'package:patient_flutter/utils/update_res.dart';

class WithdrawHistoryScreen extends StatelessWidget {
  const WithdrawHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WithdrawHistoryScreenController());
    return Scaffold(
      backgroundColor: ColorRes.white,
      body: Column(
        children: [
          TopBarArea(title: S.current.withdrawRequests),
          Expanded(
            child: GetBuilder(
              init: controller,
              builder: (context) {
                return SafeArea(
                  top: false,
                  child: controller.withdrawData == null || controller.withdrawData!.isEmpty
                      ? CustomUi.noData(title: S.current.noWithdrawRequestAvailable)
                      : ListView.builder(
                          itemCount: controller.withdrawData?.length ?? 0,
                          padding: const EdgeInsets.only(top: 3),
                          itemBuilder: (context, index) {
                            WithdrawRequestData? data = controller.withdrawData?[index];
                            return Container(
                              width: double.infinity,
                              color: ColorRes.whiteSmoke,
                              margin: const EdgeInsets.symmetric(vertical: 3),
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data?.requestNumber ?? '',
                                          style: MyTextStyle.montserratSemiBold(
                                            color: ColorRes.havelockBlue,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 2,
                                        ),
                                        Text(
                                          '${S.current.account}: ${data?.accountNumber ?? ''}',
                                          style: MyTextStyle.montserratRegular(
                                              color: ColorRes.charcoalGrey, size: 14),
                                        ),
                                        const SizedBox(
                                          height: 2,
                                        ),
                                        Text(
                                          (data?.createdAt ?? createdDate)
                                              .dateParse(ddMmmmYyyyHhMmA),
                                          style: MyTextStyle.montserratRegular(
                                              color: ColorRes.charcoalGrey, size: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        '$dollar${data?.amount ?? 0}',
                                        style: MyTextStyle.montserratBold(
                                            color: ColorRes.battleshipGrey, size: 18),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(vertical: 2, horizontal: 7),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: (data?.status == 0
                                                    ? ColorRes.pastelOrange
                                                    : data?.status == 1
                                                        ? ColorRes.irishGreen
                                                        : ColorRes.lightRed)
                                                .withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(5)),
                                        child: Text(
                                          data?.status == 0
                                              ? S.current.pending
                                              : data?.status == 1
                                                  ? S.current.completed
                                                  : S.current.rejected,
                                          style: MyTextStyle.montserratMedium(
                                              color: data?.status == 0
                                                  ? ColorRes.pastelOrange
                                                  : data?.status == 1
                                                      ? ColorRes.irishGreen
                                                      : ColorRes.lightRed,
                                              size: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
