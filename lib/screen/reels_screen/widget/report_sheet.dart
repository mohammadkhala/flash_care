import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/close_button_custom.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/common/text_button_custom.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/message/message.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/services/session_manager.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/font_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';
import 'package:patient_flutter/utils/urls.dart';

class ReportSheet extends StatefulWidget {
  final int? id;

  const ReportSheet({super.key, required this.id});

  @override
  State<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  RxString dropDownValue = reportReason.first.obs;
  TextEditingController explainController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: AppBar().preferredSize.height * 2),
      decoration: const ShapeDecoration(
          color: ColorRes.white,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius.vertical(
                top: SmoothRadius(cornerRadius: 30, cornerSmoothing: 1)),
          )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 25),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).submitReport,
                        style: const TextStyle(
                          fontFamily: FontRes.extraBold,
                          color: ColorRes.charcoalGrey,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        S
                            .of(context)
                            .pleaseExplainTheIssueBrieflyWeWillSurelyNotifyThis,
                        style: const TextStyle(
                            fontFamily: FontRes.light,
                            fontSize: 17,
                            color: ColorRes.davyGrey),
                      )
                    ],
                  ),
                ),
                const CloseButtonCustom()
              ],
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                    S.of(context).selectReason,
                    style: const TextStyle(
                        fontFamily: FontRes.regular,
                        fontSize: 16,
                        color: ColorRes.battleshipGrey),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  color: ColorRes.aquaHaze,
                  child: Obx(
                    () => DropdownButton<String>(
                      value: dropDownValue.value,
                      icon: const Icon(Icons.arrow_drop_down,
                          color: ColorRes.havelockBlue),
                      iconSize: 30,
                      elevation: 16,
                      style: const TextStyle(
                          fontFamily: FontRes.medium,
                          fontSize: 16,
                          color: ColorRes.battleshipGrey),
                      underline: const SizedBox(),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      onChanged: onChanged,
                      items: reportReason
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                            value: value, child: Text(value));
                      }).toList(),
                      isExpanded: true,
                      menuMaxHeight: 200,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                    S.of(context).explainHere,
                    style: const TextStyle(
                        fontFamily: FontRes.regular,
                        fontSize: 16,
                        color: ColorRes.battleshipGrey),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  color: ColorRes.aquaHaze,
                  height: 200,
                  child: TextField(
                      controller: explainController,
                      onTapOutside: (event) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(15)),
                      style: MyTextStyle.montserratMedium(
                          size: 16, color: ColorRes.mediumGrey)),
                ),
              ],
            ),
          )),
          TextButtonCustom(
            onPressed: onReportSubmit,
            title: S.current.submit,
            titleColor: ColorRes.white,
            backgroundColor: ColorRes.havelockBlue,
            bottomMargin: 15,
          )
        ],
      ),
    );
  }

  onChanged(String? value) {
    dropDownValue.value = value ?? '';
  }

  onReportSubmit() {
    if (explainController.text.trim().isEmpty) {
      return CustomUi.snackBar(
          message: S.of(context).pleaseExplainYourReasonBriefly);
    }
    CustomUi.loader();
    ApiService.instance.call(
      url: Urls.reportReel,
      param: {
        pReelId: widget.id,
        pReason: dropDownValue.value,
        pDescription: explainController.text.trim(),
        pReportBy: 0,
        pUserId: SessionManager.instance.getUserID()
      },
      completion: (response) {
        Message data = Message.fromJson(response);
        Get.back();
        if (data.status == true) {
          Get.back();
          CustomUi.snackBar(message: data.message);
        }
      },
    );
  }
}
