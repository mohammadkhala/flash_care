import 'package:flutter/material.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class DropDownMenu extends StatelessWidget {
  final List<String> items;
  final String initialValue;
  final double radius;
  final Color iconColor;
  final Color textColor;
  final Function(String? onChange) onChange;

  const DropDownMenu(
      {super.key,
      required this.items,
      required this.initialValue,
      required this.onChange,
      this.radius = 10,
      this.iconColor = ColorRes.charcoalGrey,
      this.textColor = ColorRes.charcoalGrey});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      decoration: BoxDecoration(color: ColorRes.whiteSmoke, borderRadius: BorderRadius.circular(radius)),
      child: DropdownButton<String>(
        value: initialValue,
        isExpanded: true,
        alignment: Alignment.center,
        onChanged: onChange,
        iconEnabledColor: iconColor,
        iconSize: 30,
        items: items
            .map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: MyTextStyle.montserratBold(size: 15, color: textColor),
                  ),
                ))
            .toList(),
        underline: const SizedBox(),
      ),
    );
  }
}
