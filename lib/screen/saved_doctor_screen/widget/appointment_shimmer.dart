import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/screen/shimmer_screen/shimmer_screen.dart';
import 'package:patient_flutter/utils/color_res.dart';

class AppointmentShimmer extends StatelessWidget {
  const AppointmentShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(color: ColorRes.whiteSmoke, borderRadius: BorderRadius.circular(0)),
        padding: const EdgeInsets.all(7),
        child: Row(
          children: [
            ShimmerScreen.rectangular(
              height: 80,
              width: 80,
              shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        children: [
                          ShimmerScreen.rectangular(
                            height: 16,
                            width: Get.width / 2.7,
                            shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          ShimmerScreen.rectangular(
                            height: 16,
                            width: Get.width / 2.7,
                            shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ShimmerScreen.rectangular(
                          height: 28,
                          width: 70,
                          shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  ShimmerScreen.rectangular(
                    height: 16,
                    width: Get.width / 1.6,
                    shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
