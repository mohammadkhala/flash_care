import 'package:flutter/material.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/font_res.dart';

class PatientTextField extends StatelessWidget {
  final double textFieldHeight;
  final String title;
  final String exampleTitle;
  final String hintTitle;
  final bool isExpand;
  final TextInputType textInputType;
  final TextEditingController controller;
  final Color textFieldColor;
  final String textFieldFontFamily;
  final TextStyle titleTextStyle;
  final FocusNode? focusNode;
  final bool isValid;
  final Color errorColor;

  const PatientTextField(
      {super.key,
      this.textFieldHeight = 50,
      required this.title,
      required this.exampleTitle,
      required this.hintTitle,
      this.isExpand = false,
      this.textInputType = TextInputType.text,
      required this.controller,
      this.textFieldColor = ColorRes.charcoalGrey,
      this.textFieldFontFamily = FontRes.semiBold,
      this.focusNode,
      required this.titleTextStyle,
      this.isValid = false,
      this.errorColor = ColorRes.whiteSmoke});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: ColorRes.white,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Text(title, style: titleTextStyle),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
        Container(
          height: textFieldHeight,
          decoration: BoxDecoration(
              color: errorColor,
              border: Border.all(color: isValid ? Colors.red : Colors.transparent),
              borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
          alignment: Alignment.center,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            expands: isExpand,
            minLines: isExpand ? null : 1,
            maxLines: isExpand ? null : 1,
            textAlignVertical: isExpand ? TextAlignVertical.top : TextAlignVertical.center,
            keyboardType: textInputType,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: isExpand ? 10 : 0),
              counterText: "",
              border: InputBorder.none,
              hintText: hintTitle,
              hintStyle: const TextStyle(
                fontFamily: FontRes.medium,
                color: ColorRes.silverChalice,
              ),
            ),
            style: TextStyle(fontFamily: textFieldFontFamily, color: textFieldColor, fontSize: 15),
            cursorHeight: 15,
            cursorColor: ColorRes.charcoalGrey,
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
      ],
    );
  }
}
