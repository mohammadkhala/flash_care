import 'package:doctor_flutter/common/common_fun.dart';
import 'package:doctor_flutter/common/top_bar_tab.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/screen/appointment_screen/appointment_screen_controller.dart';
import 'package:doctor_flutter/screen/appointment_screen/widget/appointment_card.dart';
import 'package:doctor_flutter/screen/appointment_screen/widget/qr_scanner.dart';
import 'package:doctor_flutter/utils/asset_res.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/extention.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AppointmentScreenController());
    return GetBuilder(
        init: controller,
        tag: '${DateTime.now().millisecondsSinceEpoch}',
        builder: (controller) {
          return Scaffold(
            backgroundColor: ColorRes.whiteSmoke,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TopBarTab(title: S.current.appointments),
                _AppointmentHeader(controller: controller),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DateSelector(controller: controller),
                      const SizedBox(height: 10),
                      _AppointmentCount(controller: controller),
                      const SizedBox(height: 10),
                      SearchTextField(
                          controller: controller.searchController,
                          onChanged: controller.onSearchChanged),
                      const SizedBox(height: 10),
                      AppointmentCard(controller: controller),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                CommonFun.doctorBanned(() {
                  Get.to(() => const QRViewExample());
                });
              },
              backgroundColor: const Color(0xFF00695C),
              child: Image.asset(AssetRes.scan, width: 25, color: ColorRes.white),
            ),
          );
        });
  }
}

// Header with calendar button
class _AppointmentHeader extends StatelessWidget {
  final AppointmentScreenController controller;

  const _AppointmentHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: controller.onAppointmentBoxTap,
      borderRadius: BorderRadius.circular(12),
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: FittedBox(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: ColorRes.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .07),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00897B), Color(0xFF00695C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: ColorRes.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Obx(
                  () => Text(
                    "${DateFormat.MMMM().format(controller.selectedDay.value)} ${controller.selectedDay.value.year}",
                    style: const TextStyle(
                        fontSize: 15,
                        fontFamily: FontRes.semiBold,
                        color: Color(0xFF00695C)),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF00695C),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Date Selector Widget
class _DateSelector extends StatelessWidget {
  final AppointmentScreenController controller;

  const _DateSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SizedBox(
        height: 70,
        child: ListView.builder(
          controller: controller.dateController,
          itemCount: controller.days.length,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          itemBuilder: (context, index) {
            final dateKey = GlobalKey();
            DateTime time = controller.days[index];
            return Obx(
              () {
                return DateView(
                    key: dateKey,
                    onTap: () {
                      controller.onSelectedDateClick(
                          dateTime: time, index: index);
                    },
                    isSelected: controller.selectedDay.value
                        .isSameDate(controller.days[index]),
                    time: time);
              },
            );
          },
        ),
      ),
    );
  }
}

// Appointment Count Text
class _AppointmentCount extends StatelessWidget {
  final AppointmentScreenController controller;

  const _AppointmentCount({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Obx(
        () => Text(
          "${controller.acceptAppointment.length} ${S.current.appointments}",
          style: const TextStyle(
            fontSize: 17,
            fontFamily: FontRes.semiBold,
            color: ColorRes.darkJungleGreen,
          ),
        ),
      ),
    );
  }
}

class DateView extends StatelessWidget {
  final VoidCallback onTap;
  final bool isSelected;
  final DateTime time;

  const DateView(
      {super.key,
      required this.onTap,
      required this.isSelected,
      required this.time});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 63,
        width: 63,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF00897B), Color(0xFF004D40)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : ColorRes.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : ColorRes.mercury,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00897B).withValues(alpha: .3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DateFormat.E().format(time).toUpperCase(),
              style: TextStyle(
                  color: isSelected ? ColorRes.white : ColorRes.battleshipGrey,
                  fontSize: 11,
                  fontFamily: FontRes.medium),
            ),
            const SizedBox(height: 2),
            Text(
              time.day.toString(),
              style: TextStyle(
                color: isSelected ? ColorRes.white : ColorRes.charcoalGrey,
                fontSize: 22,
                fontFamily: FontRes.semiBold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String value) onChanged;

  const SearchTextField(
      {super.key, required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: ColorRes.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: TextField(
          controller: controller,
          onChanged: onChanged,
          onTapOutside: (event) =>
              FocusManager.instance.primaryFocus?.unfocus(),
          decoration: InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF00897B),
              size: 22,
            ),
            hintText: S.current.search,
            hintStyle: const TextStyle(color: ColorRes.nobel),
          ),
          style: const TextStyle(
              fontFamily: FontRes.medium,
              fontSize: 15,
              color: ColorRes.charcoalGrey),
          cursorHeight: 15,
          cursorColor: ColorRes.charcoalGrey),
    );
  }
}
