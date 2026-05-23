import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/patient_text_filed.dart';
import 'package:patient_flutter/common/text_button_custom.dart';
import 'package:patient_flutter/common/top_bar_area.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/withdraw_request_screen/withdraw_request_screen_controller.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';
import 'package:patient_flutter/utils/update_res.dart';

class WithdrawRequestScreen extends StatelessWidget {
  const WithdrawRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WithdrawRequestScreenController());
    return Scaffold(
      backgroundColor: ColorRes.white,
      body: Column(
        children: [
          TopBarArea(title: S.current.withdrawRequest),
          Expanded(
            child: SingleChildScrollView(
              child: GetBuilder(
                init: controller,
                builder: (context) {
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(),
                            Text(
                              S.current.amount,
                              style: MyTextStyle.montserratRegular(
                                  size: 15, color: ColorRes.darkJungleGreen),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              '$dollar${controller.wallet}',
                              style: MyTextStyle.montserratRegular(
                                  size: 29, color: ColorRes.tuftsBlue),
                            ),
                          ],
                        ),
                      ),
                      PatientTextField(
                        title: S.current.bankName,
                        exampleTitle: "",
                        hintTitle: "",
                        controller: controller.bankNameController,
                        titleTextStyle: MyTextStyle.montserratSemiBold(
                          size: 15,
                          color: ColorRes.charcoalGrey,
                        ),
                        errorColor: controller.isBankName
                            ? ColorRes.bittersweet.withValues(alpha: 0.2)
                            : ColorRes.whiteSmoke,
                      ),
                      PatientTextField(
                        title: S.current.accountNumber,
                        exampleTitle: "",
                        hintTitle: "",
                        controller: controller.accountNumberController,
                        titleTextStyle:
                            MyTextStyle.montserratSemiBold(size: 15, color: ColorRes.charcoalGrey),
                        errorColor: controller.isAccountNumber
                            ? ColorRes.bittersweet.withValues(alpha: 0.2)
                            : ColorRes.whiteSmoke,
                        textInputType: TextInputType.number,
                      ),
                      PatientTextField(
                        title: S.current.reEnterAccountNumber,
                        exampleTitle: "",
                        hintTitle: "",
                        controller: controller.reAccountNumberController,
                        titleTextStyle:
                            MyTextStyle.montserratSemiBold(size: 15, color: ColorRes.charcoalGrey),
                        errorColor: controller.isReAccountNumber
                            ? ColorRes.bittersweet.withValues(alpha: 0.2)
                            : ColorRes.whiteSmoke,
                        textInputType: TextInputType.number,
                      ),
                      PatientTextField(
                        title: S.current.holdersName,
                        exampleTitle: "",
                        hintTitle: "",
                        controller: controller.holderNameController,
                        titleTextStyle:
                            MyTextStyle.montserratSemiBold(size: 15, color: ColorRes.charcoalGrey),
                        errorColor: controller.isHolderName
                            ? ColorRes.bittersweet.withValues(alpha: 0.2)
                            : ColorRes.whiteSmoke,
                      ),
                      PatientTextField(
                        title: S.current.swiftCode,
                        exampleTitle: "",
                        hintTitle: "",
                        controller: controller.swiftCodeController,
                        titleTextStyle:
                            MyTextStyle.montserratSemiBold(size: 15, color: ColorRes.charcoalGrey),
                        errorColor: controller.isSwiftCode
                            ? ColorRes.bittersweet.withValues(alpha: 0.2)
                            : ColorRes.whiteSmoke,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: TextButtonCustom(
                onPressed: controller.onSubmitTap,
                title: S.current.submit,
                titleColor: ColorRes.white,
                backgroundColor: ColorRes.darkSkyBlue),
          )
        ],
      ),
    );
  }
}
