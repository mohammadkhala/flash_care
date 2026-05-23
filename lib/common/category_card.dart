import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/home/home.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class CategoryCard extends StatelessWidget {
  final Categories? categories;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    this.categories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: ColorRes.havelockBlue.withValues(alpha: 0.1),
        ),
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: '${ConstRes.itemBaseURL}${categories?.image ?? ' '}',
              width: 33,
              height: 33,
              color: ColorRes.havelockBlue,
              errorWidget: (context, url, error) {
                return Container();
              },
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                (categories?.title ?? S.current.unKnown).capitalize ?? '',
                style: MyTextStyle.montserratMedium(size: 15, color: ColorRes.havelockBlue),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
