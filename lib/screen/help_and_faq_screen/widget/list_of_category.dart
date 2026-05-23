import 'package:flutter/material.dart';
import 'package:patient_flutter/model/global/fetch_faqs.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class ListOfCategory extends StatelessWidget {
  final List<FetchFaqsData> faqs;
  final Function(int index) onCategoryChange;
  final int selectedCategory;

  const ListOfCategory({
    super.key,
    required this.faqs,
    required this.onCategoryChange,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => onCategoryChange(index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5, vertical: 5),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: selectedCategory == index ? MyTextStyle.linearTopGradient : MyTextStyle.linearGreyGradient,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                faqs[index].title ?? '',
                style: MyTextStyle.montserratSemiBold(
                  size: 14,
                  color: selectedCategory == index ? ColorRes.white : ColorRes.grey,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
