import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/close_button_custom.dart';
import 'package:patient_flutter/common/text_button_custom.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/recharge_wallet_sheet/recharge_wallet_sheet_controller.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';
import 'package:patient_flutter/utils/update_res.dart';

class RechargeWalletSheet extends StatelessWidget {
  final int screenType;
  final Function(int amount)? onUpdateAmount;

  const RechargeWalletSheet({super.key, required this.screenType, this.onUpdateAmount});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RechargeWalletSheetController(onUpdateAmount));
    return Container(
      padding: const EdgeInsets.only(top: 30, left: 15, right: 15, bottom: 10),
      decoration: const BoxDecoration(
          color: ColorRes.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      margin: EdgeInsets.only(top: AppBar().preferredSize.height * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      screenType == 1 ? S.current.rechargeWallet : S.current.insufficientBalance,
                      style:
                          MyTextStyle.montserratExtraBold(size: 20, color: ColorRes.charcoalGrey),
                    ),
                    Text(
                      screenType == 1
                          ? S.current.addMoneyToYourWallet
                          : S.current.thereIsNotEnoughEtc,
                      style: MyTextStyle.montserratLight(size: 16, color: ColorRes.davyGrey),
                    ),
                  ],
                ),
              ),
              const CloseButtonCustom()
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 35),
                    child: GetBuilder(
                      init: controller,
                      builder: (context) {
                        return Text(
                          '${controller.settings?.currency}${controller.selectedAmount}',
                          style: MyTextStyle.montserratRegular(size: 39, color: ColorRes.tuftsBlue),
                        );
                      },
                    ),
                  ),
                  Text(
                    S.current.pleaseRechargeEtc,
                    style: MyTextStyle.montserratLight(size: 16, color: ColorRes.davyGrey),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Text(
                    S.current.selectAmount,
                    style: MyTextStyle.montserratBold(size: 16, color: ColorRes.davyGrey),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GetBuilder(
                      init: controller,
                      builder: (controller) {
                        return Wrap(
                          children: List.generate(
                            controller.list.length,
                            (index) {
                              return FittedBox(
                                child: InkWell(
                                  onTap: () {
                                    controller.onCategoryChange(index);
                                  },
                                  child: Container(
                                    height: 40,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 30,
                                    ),
                                    margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                                    decoration: BoxDecoration(
                                        color: controller.selectedAmountIndex == index
                                            ? ColorRes.havelockBlue
                                            : ColorRes.softPeach,
                                        borderRadius: BorderRadius.circular(30)),
                                    child: Text(
                                      controller.list[index] == otherCap
                                          ? controller.list[index]
                                          : '${controller.settings?.currency}${controller.list[index]}',
                                      style: MyTextStyle.montserratSemiBold(
                                        size: 14,
                                        color: controller.selectedAmountIndex == index
                                            ? ColorRes.white
                                            : ColorRes.charcoalGrey,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                  const SizedBox(
                    height: 10,
                  ),
                  GetBuilder(
                    init: controller,
                    builder: (context) {
                      return Visibility(
                        visible: controller.list[controller.selectedAmountIndex ?? 0] == otherCap
                            ? true
                            : false,
                        child: InkWell(
                          onTap: () => controller.onCategoryChange(controller.list.length - 1),
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                                color: ColorRes.whiteSmoke,
                                borderRadius: BorderRadius.circular(15)),
                            alignment: Alignment.center,
                            child: TextField(
                              controller: controller.amountController,
                              onTap: () => controller.onCategoryChange(controller.list.length - 1),
                              onTapUpOutside: (event) =>
                                  FocusManager.instance.primaryFocus?.unfocus(),
                              maxLength: 6,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                counterText: '',
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                                hintText: S.current.enterAmountOfYourChoice,
                                hintStyle: MyTextStyle.montserratSemiBold(
                                    size: 15, color: ColorRes.silverChalice),
                              ),
                              onChanged: controller.onTextChange,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              style: MyTextStyle.montserratSemiBold(
                                  size: 15, color: ColorRes.battleshipGrey),
                              cursorHeight: 15,
                              cursorColor: ColorRes.battleshipGrey,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  )
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: TextButtonCustom(
                onPressed: () => controller.onContinueTap(screenType),
                title: S.current.continueText,
                titleColor: ColorRes.white,
                backgroundColor: ColorRes.darkSkyBlue),
          )
        ],
      ),
    );
  }
}
