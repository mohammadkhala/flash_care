import 'package:flutter/material.dart';
import 'package:patient_flutter/common/image_builder_custom.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/doctor/fetch_doctor.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/extention.dart';
import 'package:patient_flutter/utils/my_text_style.dart';
import 'package:patient_flutter/utils/update_res.dart';

class DoctorCard extends StatelessWidget {
  final int index;
  final bool isBookMarkVisible;
  final Color color;
  final VoidCallback onTap;
  final DoctorData? doctorData;
  final bool? isBookMark;
  final Function(int? doctorId)? onBookMarkTap;

  const DoctorCard({
    super.key,
    required this.index,
    this.isBookMarkVisible = true,
    this.color = const Color(0xFFF6FAF8),
    required this.onTap,
    this.doctorData,
    this.onBookMarkTap,
    this.isBookMark = false,
  });

  @override
  Widget build(BuildContext context) {
    final rating = doctorData?.rating;
    final hasRating = rating != null && rating.toInt() != 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00695C).withValues(alpha: .07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Info ─────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Rating + Name row
                  Row(
                    children: [
                      // Rating badge (left in RTL)
                      if (hasRating)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 14, color: Color(0xFFF59E2A)),
                              const SizedBox(width: 3),
                              Text(
                                rating.toStringAsFixed(1).replaceAll('0.0', '0'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'ProductSans-Bold',
                                  color: Color(0xFFF59E2A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),
                      // Doctor name
                      Flexible(
                        child: Text(
                          doctorData?.name ?? S.current.unKnown,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 15,
                            fontFamily: 'ProductSans-Bold',
                            color: Color(0xFF171D1B),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Specialty / designation
                  Text(
                    doctorData?.designation ?? doctorData?.degrees ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'ProductSans-Regular',
                      color: Color(0xFF00897B),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Availability / fee row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Fee
                      Text(
                        '$dollar${(doctorData?.consultationFee ?? 0).numFormat} / جلسة',
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'ProductSans-Bold',
                          color: Color(0xFF171D1B),
                        ),
                      ),
                      // Availability
                      Row(
                        children: [
                          const Icon(Icons.check_circle_outline_rounded,
                              size: 14, color: Color(0xFF00897B)),
                          const SizedBox(width: 4),
                          Text(
                            'متاح اليوم',
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'ProductSans-Regular',
                              color: Color(0xFF00897B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // View profile + bookmark row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bookmark
                      if (isBookMarkVisible && onBookMarkTap != null)
                        GestureDetector(
                          onTap: () => onBookMarkTap!(doctorData?.id),
                          child: Icon(
                            isBookMark == true
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            size: 22,
                            color: isBookMark == true
                                ? const Color(0xFF00897B)
                                : const Color(0xFFBCC9C5),
                          ),
                        )
                      else
                        const SizedBox(),
                      // View profile link
                      Text(
                        'عرض الملف',
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'ProductSans-Medium',
                          color: Color(0xFF00897B),
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF00897B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // ── Doctor image ──────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: ImageBuilderCustom(
                doctorData?.image,
                name: doctorData?.name,
                size: 90,
                radius: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
