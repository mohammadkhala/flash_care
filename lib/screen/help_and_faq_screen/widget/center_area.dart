import 'package:flutter/material.dart';
import 'package:patient_flutter/model/global/fetch_faqs.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class CenterArea extends StatelessWidget {
  final List<Faqs> faqs;

  const CenterArea({
    super.key,
    required this.faqs,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          Faqs? data = faqs[index];
          return Container(
            color: ColorRes.whiteSmoke,
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.question ?? '',
                  style: MyTextStyle.montserratBold(size: 15, color: ColorRes.charcoalGrey),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  data.answer ?? '',
                  style: MyTextStyle.montserratLight(size: 15, color: ColorRes.battleshipGrey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
