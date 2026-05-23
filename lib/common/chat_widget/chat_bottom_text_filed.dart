import 'package:flutter/material.dart';
import 'package:patient_flutter/utils/asset_res.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class ChatBottomTextFiled extends StatelessWidget {
  final TextEditingController msgController;
  final VoidCallback onSendTap;
  final VoidCallback onTextFiledTap;

  const ChatBottomTextFiled({
    super.key,
    required this.msgController,
    required this.onSendTap,
    required this.onTextFiledTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: double.infinity,
          color: ColorRes.snowDrift,
          padding:
              const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
          alignment: Alignment.center,
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                        color: ColorRes.dawnPink,
                        borderRadius: BorderRadius.circular(30)),
                    child: TextField(
                      controller: msgController,
                      onTap: onTextFiledTap,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                        isDense: true,
                        suffixIconConstraints: BoxConstraints(),
                        suffixIcon: InkWell(
                          onTap: onSendTap,
                          child: Container(
                            height: 43,
                            width: 43,
                            margin: EdgeInsets.symmetric(horizontal: 3),
                            alignment: const Alignment(0.15, 0),
                            decoration: const BoxDecoration(
                              gradient: MyTextStyle.linearTopGradient,
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              AssetRes.icSend,
                              color: ColorRes.white,
                              height: 25,
                              width: 25,
                            ),
                          ),
                        ),
                      ),
                      style: MyTextStyle.montserratRegular(
                          size: 14, color: ColorRes.davyGrey),
                      cursorHeight: 14,
                      cursorColor: ColorRes.davyGrey,
                      textCapitalization: TextCapitalization.sentences,
                      onTapOutside: (event) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                const SizedBox(height: 38, width: 38)
              ],
            ),
          ),
        ),
      ],
    );
  }
}
