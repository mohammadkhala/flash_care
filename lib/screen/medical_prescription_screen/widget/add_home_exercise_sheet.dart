import 'package:doctor_flutter/common/doctor_profile_text_filed.dart';
import 'package:doctor_flutter/common/text_button_custom.dart';
import 'package:doctor_flutter/model/medical_prescription.dart';
import 'package:doctor_flutter/screen/medical_prescription_screen/medical_prescription_screen_controller.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddHomeExerciseSheet extends StatefulWidget {
  final MedicalPrescriptionScreenController controller;

  const AddHomeExerciseSheet({super.key, required this.controller});

  @override
  State<AddHomeExerciseSheet> createState() => _AddHomeExerciseSheetState();
}

class _AddHomeExerciseSheetState extends State<AddHomeExerciseSheet> {
  final titleCtrl = TextEditingController();
  final repsCtrl = TextEditingController();
  final setsCtrl = TextEditingController();
  final durationCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  bool titleError = false;

  @override
  void dispose() {
    titleCtrl.dispose();
    repsCtrl.dispose();
    setsCtrl.dispose();
    durationCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (titleCtrl.text.trim().isEmpty) {
      setState(() => titleError = true);
      return;
    }
    widget.controller.onAddHomeExercise(HomeExercise(
      title: titleCtrl.text.trim(),
      reps: repsCtrl.text.trim(),
      sets: setsCtrl.text.trim(),
      duration: durationCtrl.text.trim(),
      notes: notesCtrl.text.trim(),
    ));
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: EdgeInsets.only(top: AppBar().preferredSize.height),
      decoration: const BoxDecoration(
        color: ColorRes.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 10),
            child: Row(
              children: [
                const Text(
                  'إضافة تمرين',
                  style: TextStyle(
                    fontFamily: FontRes.extraBold,
                    color: ColorRes.charcoalGrey,
                    fontSize: 20,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => Get.back(),
                  child: Container(
                    height: 37,
                    width: 37,
                    decoration: const BoxDecoration(
                        color: ColorRes.iceberg, shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded,
                        color: ColorRes.havelockBlue, size: 22),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DoctorProfileTextField(
                    isExample: false,
                    title: 'اسم التمرين *',
                    exampleTitle: '',
                    hintTitle: 'مثال: تمرين رفع الذراع',
                    controller: titleCtrl,
                    hintTextColor:
                        titleError ? ColorRes.bittersweet : ColorRes.silverChalice,
                    errorColor: titleError
                        ? ColorRes.bittersweet.withValues(alpha: 0.2)
                        : ColorRes.whiteSmoke,
                  ),
                  DoctorProfileTextField(
                    isExample: false,
                    title: 'التكرارات',
                    exampleTitle: '',
                    hintTitle: 'مثال: 10 مرات',
                    controller: repsCtrl,
                    hintTextColor: ColorRes.silverChalice,
                    errorColor: ColorRes.whiteSmoke,
                  ),
                  DoctorProfileTextField(
                    isExample: false,
                    title: 'المجموعات',
                    exampleTitle: '',
                    hintTitle: 'مثال: 3 مجموعات',
                    controller: setsCtrl,
                    hintTextColor: ColorRes.silverChalice,
                    errorColor: ColorRes.whiteSmoke,
                  ),
                  DoctorProfileTextField(
                    isExample: false,
                    title: 'المدة',
                    exampleTitle: '',
                    hintTitle: 'مثال: 15 دقيقة',
                    controller: durationCtrl,
                    hintTextColor: ColorRes.silverChalice,
                    errorColor: ColorRes.whiteSmoke,
                  ),
                  DoctorProfileTextField(
                    isExpand: true,
                    textFieldHeight: 80,
                    title: 'ملاحظات',
                    exampleTitle: '',
                    hintTitle: 'أي تعليمات إضافية...',
                    controller: notesCtrl,
                    hintTextColor: ColorRes.silverChalice,
                    errorColor: ColorRes.whiteSmoke,
                  ),
                ],
              ),
            ),
          ),
          TextButtonCustom(
            onPressed: _submit,
            title: 'إضافة',
            titleColor: ColorRes.white,
            backgroundColor: ColorRes.havelockBlue,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
