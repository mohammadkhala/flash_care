import 'package:flutter/material.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/font_res.dart';

class BookingTopCard extends StatelessWidget {
  const BookingTopCard({
    super.key,
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 15, color: ColorRes.battleshipGrey),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          value,
          style: const TextStyle(
              fontSize: 16,
              color: ColorRes.tuftsBlue,
              fontFamily: FontRes.semiBold),
        ),
      ],
    );
  }
}
