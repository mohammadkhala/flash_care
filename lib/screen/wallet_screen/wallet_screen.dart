import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/common/top_bar_area.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/wallet/wallet_statement.dart';
import 'package:patient_flutter/screen/wallet_screen/wallet_screen_controller.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/extention.dart';
import 'package:patient_flutter/utils/my_text_style.dart';
import 'package:patient_flutter/utils/update_res.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WalletScreenController());
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TopBarArea(title: S.current.wallet),
          Card(
            elevation: 3,
            margin: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: MyTextStyle.linearLeftGradient,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GetBuilder(
                      init: controller,
                      builder: (context) {
                        return Text(
                          '$dollar${(controller.userData?.wallet ?? 0).formatCurrency}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              MyTextStyle.montserratLight(size: 28, color: ColorRes.white).copyWith(
                            letterSpacing: 0.5,
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: controller.onAddBtnClick,
                      child: Container(
                        decoration: BoxDecoration(
                          color: ColorRes.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        child: Text(
                          S.current.add,
                          style: MyTextStyle.montserratMedium(size: 14, color: ColorRes.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => controller.onWithdrawTap(controller.userData),
                      child: Container(
                        decoration: BoxDecoration(
                          color: ColorRes.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        child: Text(
                          S.current.withdraw,
                          style: MyTextStyle.montserratMedium(size: 14, color: ColorRes.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              S.current.statement,
              style: MyTextStyle.montserratRegular(color: ColorRes.darkJungleGreen),
            ),
          ),
          _statements(controller)
        ],
      ),
    );
  }

  Widget _statements(WalletScreenController controller) {
    return Expanded(
      child: SafeArea(
        top: false,
        child: GetBuilder(
          init: controller,
          builder: (context) {
            return controller.isLoading && controller.walletData.isEmpty
                ? CustomUi.loaderWidget()
                : !controller.isLoading && controller.walletData.isEmpty
                    ? CustomUi.noData(title: S.current.noDataAvailable)
                    : ListView.builder(
                        controller: controller.statementController,
                        itemCount: controller.walletData.length,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          WalletStatementData? data = controller.walletData[index];
                          return Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.symmetric(vertical: 1),
                            color: data.crOrDr == 1
                                ? ColorRes.mediumGreen.withValues(alpha: 0.08)
                                : ColorRes.bittersweet.withValues(alpha: 0.08),
                            child: Row(
                              children: [
                                Container(
                                  height: 28,
                                  width: 28,
                                  decoration: BoxDecoration(
                                    color: data.crOrDr == 1
                                        ? ColorRes.mediumGreen
                                        : ColorRes.bittersweet,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    data.crOrDr == 1 ? Icons.add_rounded : Icons.remove_rounded,
                                    size: 20,
                                    color: ColorRes.white,
                                  ),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: Get.width / 2.7,
                                            child: Text(
                                              "${data.transactionId ?? ''} -",
                                              style: MyTextStyle.montserratSemiBold(
                                                color: ColorRes.smokeyGrey,
                                                size: 13,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            (data.type == 0
                                                    ? S.current.deposit
                                                    : data.type == 1
                                                        ? S.current.purchase
                                                        : data.type == 2
                                                            ? S.current.withdraw
                                                            : S.current.refund)
                                                .toUpperCase(),
                                            style: MyTextStyle.montserratSemiBold(
                                              color: data.crOrDr == 1
                                                  ? ColorRes.mediumGreen
                                                  : ColorRes.bittersweet,
                                              size: 13,
                                            ).copyWith(
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        (data.createdAt ?? createdDate)
                                            .dateParse(eeeDdMmmYyyyHhMmA),
                                        style: MyTextStyle.montserratRegular(
                                            size: 12, color: ColorRes.smokeyGrey),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  NumberFormat.compactCurrency(
                                          decimalDigits: 2, name: inr, symbol: dollar)
                                      .format(data.amount ?? 0),
                                  style: MyTextStyle.montserratSemiBold(
                                      size: 17, color: ColorRes.smokeyGrey),
                                )
                              ],
                            ),
                          );
                        },
                      );
          },
        ),
      ),
    );
  }
}
