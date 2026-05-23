import 'dart:convert';
import 'dart:ui';

import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/close_button_custom.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/custom/countries.dart';
import 'package:patient_flutter/utils/asset_res.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/font_res.dart';

class MobileNumberBox extends StatefulWidget {
  final Function(Country?) onSelectedCountry;
  final Country? selectedCountry;

  const MobileNumberBox(
      {super.key, required this.onSelectedCountry, this.selectedCountry});

  @override
  State<MobileNumberBox> createState() => _MobileNumberBoxState();
}

class _MobileNumberBoxState extends State<MobileNumberBox> {
  Country? selectedCountry;

  @override
  void initState() {
    selectedCountry = widget.selectedCountry;
    print('----${widget.selectedCountry?.toJson()}');
    setState(() {});
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
          height: 50,
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.symmetric(horizontal: 5),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: ColorRes.darkJungleGreen,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 10),
              CountryFlag.fromCountryCode(
                shape: const RoundedRectangle(3),
                selectedCountry?.countryCode ?? countryCode,
                width: 20,
                height: 15,
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
                        color: ColorRes.darkJungleGreen,
                        fontFamily: FontRes.semiBold,
                        fontSize: 18),
                  ),
                  const Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: CloseButtonCustom())
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: ColorRes.whiteSmoke,
                ),
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 15),
                  ),
                  cursorColor: ColorRes.darkJungleGreen,
                  style: const TextStyle(
                      color: ColorRes.darkJungleGreen,
                      fontFamily: FontRes.medium,
                      fontSize: 15),
                ),
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
                          color: ColorRes.snowDrift,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          CountryFlag.fromCountryCode(
                            shape: const RoundedRectangle(3),
                            filterCountries[index].countryCode ?? countryCode,
                            width: 25,
                            height: 20,
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
                                      color: ColorRes.darkJungleGreen,
                                      fontFamily: FontRes.medium,
                                      fontSize: 15),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  filterCountries[index].phoneCode ?? phoneCode,
                                  style: const TextStyle(
                                      color: ColorRes.silverChalice,
                                      fontFamily: FontRes.regular,
                                      fontSize: 14),
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
