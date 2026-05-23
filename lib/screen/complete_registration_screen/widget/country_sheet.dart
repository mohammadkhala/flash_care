import 'package:flutter/material.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/custom/countries.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class CountrySheet extends StatelessWidget {
  final List<Country> country;
  final Function(String name) onCountryChange;
  final TextEditingController controller;
  final Function(Country countryName) onCountryTap;

  const CountrySheet(
      {super.key,
      required this.country,
      required this.onCountryChange,
      required this.onCountryTap,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.8,
      child: Container(
        margin: EdgeInsets.only(top: AppBar().preferredSize.height),
        decoration:
            const BoxDecoration(color: ColorRes.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.current.selectCountry,
              style: MyTextStyle.montserratBold(
                color: ColorRes.charcoalGrey,
                size: 19,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: ColorRes.whiteSmoke,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    hintText: 'Search country name',
                    hintStyle: MyTextStyle.montserratSemiBold(size: 14, color: ColorRes.nobel)),
                style: MyTextStyle.montserratMedium(size: 14, color: ColorRes.charcoalGrey),
                onChanged: onCountryChange,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                primary: false,
                shrinkWrap: true,
                itemCount: country.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  Country c = country[index];
                  return InkWell(
                    onTap: () => onCountryTap(c),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                      child: Text(
                        c.countryName ?? '',
                        style: MyTextStyle.montserratSemiBold(color: ColorRes.charcoalGrey, size: 14),
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
