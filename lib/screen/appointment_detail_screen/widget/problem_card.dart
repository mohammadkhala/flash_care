import 'package:flutter/material.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class ProblemCard extends StatelessWidget {
  final String title;
  final String description;

  const ProblemCard({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          child: Text(
            title,
            style: MyTextStyle.montserratRegular(color: ColorRes.battleshipGrey, size: 15),
          ),
        ),
        Container(
          width: double.infinity,
          color: ColorRes.snowDrift,
          padding: const EdgeInsets.all(15),
          margin: const EdgeInsets.only(bottom: 10),
          child: Text(
            description,
            style: MyTextStyle.montserratMedium(size: 15, color: ColorRes.battleshipGrey),
          ),
        ),
      ],
    );
  }
}
