import 'package:doctor_flutter/utils/asset_res.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:doctor_flutter/utils/style_res.dart';
import 'package:flutter/material.dart';

class ChatBottomTextFiled extends StatelessWidget {
  final TextEditingController msgController;
  final VoidCallback onSendTap;
  final VoidCallback onTextFiledTap;
  final FocusNode msgFocusNode;

  const ChatBottomTextFiled({super.key,
      required this.msgController,
      required this.onSendTap,
      required this.onTextFiledTap,
      required this.msgFocusNode});

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
                      focusNode: msgFocusNode,
                      textAlignVertical: TextAlignVertical.center,
                      onTapOutside: (event) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        isDense: true,
                        suffixIconConstraints: const BoxConstraints(),
                        suffixIcon: InkWell(
                          onTap: onSendTap,
                          child: Container(
                              height: 43,
                              width: 43,
                              decoration: const BoxDecoration(
                                gradient: StyleRes.linearGradient,
                                shape: BoxShape.circle,
                              ),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              alignment: const Alignment(0.1, 0),
                              child: Image.asset(AssetRes.icSend,
                                  color: ColorRes.white,
                                  height: 25,
                                  width: 25)),
                        ),
                      ),
                      style: const TextStyle(
                          fontSize: 14,
                          fontFamily: FontRes.regular,
                          color: ColorRes.davyGrey),
                      cursorHeight: 14,
                      cursorColor: ColorRes.davyGrey,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                ),
                const SizedBox(height: 35, width: 35)
              ],
            ),
          ),
        ),
      ],
    );
  }
}
