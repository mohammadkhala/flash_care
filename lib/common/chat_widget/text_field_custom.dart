import 'package:flutter/material.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class TextFieldCustom extends StatelessWidget {
  final Widget? prefixIcon;
  final TextEditingController controller;

  const TextFieldCustom({super.key, this.prefixIcon, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
          color: ColorRes.silverChalice.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10)),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        textAlignVertical: TextAlignVertical.center,
        decoration:
            InputDecoration(isDense: true, border: InputBorder.none, prefixIcon: prefixIcon),
        textCapitalization: TextCapitalization.sentences,
        style: MyTextStyle.montserratBold(size: 17, color: ColorRes.charcoalGrey),
        cursorColor: ColorRes.charcoalGrey,
        cursorHeight: 17,
        onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      ),
    );
  }
}
