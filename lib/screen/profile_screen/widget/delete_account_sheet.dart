import 'package:flutter/material.dart';
import 'package:patient_flutter/common/close_button_custom.dart';
import 'package:patient_flutter/common/text_button_custom.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class DeleteAccountSheet extends StatelessWidget {
  final VoidCallback onDeleteContinueTap;
  final String title;
  final String description;

  const DeleteAccountSheet(
      {super.key, required this.onDeleteContinueTap, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: MyTextStyle.montserratExtraBold(size: 20, color: ColorRes.charcoalGrey),
                    ),
                  ),
                  const CloseButtonCustom()
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                description,
                style: MyTextStyle.montserratLight(size: 16, color: ColorRes.davyGrey),
              ),
              const SizedBox(
                height: 50,
              ),
              SafeArea(
                top: false,
                child: TextButtonCustom(
                  onPressed: onDeleteContinueTap,
                  title: S.current.continueText,
                  titleColor: ColorRes.white,
                  backgroundColor: ColorRes.darkSkyBlue,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
