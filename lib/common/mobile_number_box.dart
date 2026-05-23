import 'dart:convert';
import 'dart:ui';

import 'package:country_flags/country_flags.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/countries/countries.dart';
import 'package:doctor_flutter/utils/asset_res.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/const_res.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class MobileNumberBox extends StatefulWidget {
  final Function(Country?) onSelectedCountry;
  final Country? selectedCountry;
  final bool isRadius;

  const MobileNumberBox(
      {super.key,
      required this.onSelectedCountry,
      this.selectedCountry,
      this.isRadius = true});

  @override
  State<MobileNumberBox> createState() => _MobileNumberBoxState();
}

class _MobileNumberBoxState extends State<MobileNumberBox> {
  Country? selectedCountry;

  @override
  void initState() {
    fetchSelectedCountry();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.bottomSheet(
          CountrySheet(
            onTap: (p0) {
              FocusManager.instance.primaryFocus?.unfocus();
              selectedCountry = p0;
              widget.onSelectedCountry.call(selectedCountry);
              setState(() {});
            },
          ),
        );
      },
      child: FittedBox(
        fit: BoxFit.none,
        alignment: Alignment.center,
        child: Container(
          height: 48,
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ColorRes.charcoalGrey,
            borderRadius: !widget.isRadius
                ? null
                : const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    topLeft: Radius.circular(10),
                  ),
          ),
          child: Row(
            children: [
              CountryFlag.fromCountryCode(
                selectedCountry?.countryCode ?? countryCode,
                width: 20,
                height: 15,
                shape: const RoundedRectangle(3),
              ),
              const SizedBox(width: 10),
              Text(
                selectedCountry?.phoneCode ?? phoneCode,
                style: const TextStyle(
                  color: ColorRes.white,
                  fontFamily: FontRes.medium,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void fetchSelectedCountry() async {
    String response = await rootBundle.loadString(AssetRes.countryJson);
    Countries? countries = Countries.fromJson(jsonDecode(response));
    selectedCountry = countries.country?.firstWhere(
      (element) => element.phoneCode == widget.selectedCountry?.phoneCode,
      orElse: () => Country(),
    );
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant MobileNumberBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    fetchSelectedCountry();
  }
}

class CountrySheet extends StatefulWidget {
  final Function(Country countri) onTap;

  const CountrySheet({super.key, required this.onTap});

  @override
  State<CountrySheet> createState() => _CountrySheetState();
}

class _CountrySheetState extends State<CountrySheet> {
  List<Country> filterCountries = [];
  TextEditingController controller = TextEditingController();
  Countries? countries;
  CountryFlag? countryFlag;

  @override
  void initState() {
    super.initState();
    getCountryData();

    controller.addListener(_filterCountries);
  }

  void getCountryData() async {
    String response = await rootBundle.loadString(AssetRes.countryJson);
    countries = Countries.fromJson(jsonDecode(response));

    filterCountries = countries?.country ?? [];
    countryFlag = CountryFlag.fromCountryCode(countryCode);

    setState(() {});
  }

  void _filterCountries() {
    setState(() {
      filterCountries = (countries?.country ?? [])
          .where((country) => country.countryName!
              .toLowerCase()
              .contains(controller.text.trim().toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    controller.removeListener(_filterCountries);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.only(top: 20),
        decoration: const BoxDecoration(
          color: ColorRes.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Stack(
                alignment: AlignmentDirectional.centerStart,
                children: [
                  Text(
                    S.of(context).selectCountry,
                    style: const TextStyle(
                        color: ColorRes.havelockBlue,
                        fontFamily: FontRes.semiBold,
                        fontSize: 18),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Container(
                      height: 37,
                      width: 37,
                      decoration: const BoxDecoration(
                          color: ColorRes.iceberg, shape: BoxShape.circle),
                      child: const Icon(
                        Icons.close_rounded,
                        color: ColorRes.havelockBlue,
                        size: 22,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: ColorRes.aquaHaze,
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(15),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: S.current.searchCountryName,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    hintStyle: const TextStyle(color: ColorRes.silverChalice)),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filterCountries.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      widget.onTap(filterCountries[index]);
                      Get.back();
                    },
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      decoration: BoxDecoration(
                          color: ColorRes.aquaHaze,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          CountryFlag.fromCountryCode(
                            shape: const RoundedRectangle(3),
                            filterCountries[index].countryCode ?? countryCode,
                            width: 20,
                            height: 15,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  filterCountries[index].countryName ??
                                      countryName,
                                  style: const TextStyle(
                                      color: ColorRes.havelockBlue,
                                      fontFamily: FontRes.medium,
                                      fontSize: 15),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  filterCountries[index].phoneCode ?? phoneCode,
                                  style: const TextStyle(
                                    color: ColorRes.silverChalice,
                                    fontFamily: FontRes.light,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
