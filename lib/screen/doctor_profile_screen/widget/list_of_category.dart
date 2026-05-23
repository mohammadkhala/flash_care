import 'package:flutter/material.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class ListOfCategory extends StatelessWidget {
  final List<String> categories;
  final int selectedCategoryIndex;
  final Function(int index) onCategoryChange;

  const ListOfCategory(
      {super.key, required this.categories, required this.selectedCategoryIndex, required this.onCategoryChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => onCategoryChange(index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selectedCategoryIndex == index ? ColorRes.tuftsBlue : ColorRes.whiteSmoke,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                categories[index],
                style: MyTextStyle.montserratSemiBold(
                  size: 14,
                  color: selectedCategoryIndex == index ? ColorRes.white : ColorRes.grey,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
