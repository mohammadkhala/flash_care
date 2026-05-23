import 'package:flutter/material.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/doctor_profile_screen/doctor_profile_screen_controller.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/font_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceLocation extends StatelessWidget {
  final DoctorProfileScreenController controller;

  const ServiceLocation({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorRes.snowDrift,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 5,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text(
              S.current.servicesLocation,
              style: MyTextStyle.montserratSemiBold(size: 14, color: ColorRes.charcoalGrey).copyWith(letterSpacing: 1),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          _serviceLocationCard(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _openMap(String lat, String lng, String label) async {
    final encodedLabel = Uri.encodeComponent(label);
    final googleUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng($encodedLabel)';
    final appleUrl = 'maps://?q=$encodedLabel&ll=$lat,$lng';
    final uri = Uri.parse(googleUrl);
    final appleUri = Uri.parse(appleUrl);
    if (await canLaunchUrl(appleUri)) {
      await launchUrl(appleUri);
    } else if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _serviceLocationCard() {
    if (controller.doctorData?.serviceLocations == null || controller.doctorData!.serviceLocations!.isEmpty) {
      return CustomUi.noData(title: S.current.noServiceLocation);
    } else {
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: controller.doctorData?.serviceLocations?.length ?? 0,
        shrinkWrap: true,
        primary: false,
        itemBuilder: (context, index) {
          final loc = controller.doctorData?.serviceLocations?[index];
          final hasCoords = (loc?.hospitalLat != null && loc!.hospitalLat!.isNotEmpty) &&
              (loc.hospitalLong != null && loc.hospitalLong!.isNotEmpty);
          return InkWell(
            onTap: hasCoords
                ? () => _openMap(loc!.hospitalLat!, loc.hospitalLong!, loc.hospitalTitle ?? '')
                : null,
            child: Container(
              color: index % 2 == 0 ? ColorRes.whiteSmoke : ColorRes.snowDrift,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc?.hospitalTitle ?? '',
                          style: const TextStyle(
                              fontSize: 15, fontFamily: FontRes.bold, color: ColorRes.davyGrey, overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          loc?.hospitalAddress ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: ColorRes.davyGrey,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                  if (hasCoords)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00897B).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.map_rounded, color: Color(0xFF00897B), size: 20),
                    ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
