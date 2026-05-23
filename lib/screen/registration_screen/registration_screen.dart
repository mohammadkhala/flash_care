import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/common_fun.dart';
import 'package:patient_flutter/common/text_button_custom.dart';
import 'package:patient_flutter/common/top_bar_area.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/registration_screen/registration_screen_controller.dart';
import 'package:patient_flutter/utils/asset_res.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegistrationScreenController>(
      init: RegistrationScreenController(),
      builder: (controller) {
        return Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back arrow navigates between steps
              TopBarArea(
                title: S.of(context).registration,
                onBack: controller.goBack,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _StepIndicator(current: controller.step, total: 3),
                        const SizedBox(height: 20),

                        // ── Step 0: phone ───────────────────────────────
                        if (controller.step == 0) ...[
                          Text(
                            'Enter your WhatsApp number to receive a verification code.',
                            style: MyTextStyle.montserratRegular(
                                color: ColorRes.battleshipGrey),
                          ),
                          const SizedBox(height: 30),
                          Text('WhatsApp Phone Number',
                              style: MyTextStyle.montserratRegular(
                                  color: ColorRes.battleshipGrey, size: 16)),
                          const SizedBox(height: 8),
                          _PhoneFieldWithCode(
                            controller: controller.phoneController,
                            selectedCode: controller.selectedCountryCode,
                            onCodeChanged: controller.onCountryCodeChanged,
                            isError: controller.phoneError,
                          ),
                          const SizedBox(height: 30),
                          TextButtonCustom(
                            onPressed: controller.onSendOtpClick,
                            title: 'Send OTP via WhatsApp',
                            titleColor: ColorRes.darkSkyBlue,
                            backgroundColor:
                                ColorRes.darkSkyBlue.withValues(alpha: 0.2),
                          ),
                        ],

                        // ── Step 1: OTP ─────────────────────────────────
                        if (controller.step == 1) ...[
                          Text(
                            'Enter the 6-digit code sent to your WhatsApp.',
                            style: MyTextStyle.montserratRegular(
                                color: ColorRes.battleshipGrey),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            controller.phoneController.text,
                            style: MyTextStyle.montserratRegular(
                                color: ColorRes.havelockBlue),
                          ),
                          const SizedBox(height: 30),
                          _RegField(
                            title: 'Verification Code (OTP)',
                            hint: '000000',
                            controller: controller.otpController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                          ),
                          const SizedBox(height: 30),
                          TextButtonCustom(
                            onPressed: controller.onVerifyOtpClick,
                            title: 'Verify Phone Number',
                            titleColor: ColorRes.darkSkyBlue,
                            backgroundColor:
                                ColorRes.darkSkyBlue.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: InkWell(
                              onTap: controller.onResendOtp,
                              child: Text(
                                'Resend OTP',
                                style: MyTextStyle.montserratRegular(
                                    color: ColorRes.havelockBlue),
                              ),
                            ),
                          ),
                        ],

                        // ── Step 2: name + password ─────────────────────
                        if (controller.step == 2) ...[
                          Text(
                            'Complete your account details.',
                            style: MyTextStyle.montserratRegular(
                                color: ColorRes.battleshipGrey),
                          ),
                          const SizedBox(height: 30),
                          _RegField(
                            title: S.of(context).fullname,
                            controller: controller.fullNameController,
                            isError: controller.fullNameError,
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                          _PasswordRegField(
                            title: S.of(context).password,
                            controller: controller.passwordController,
                            isError: controller.passwordError,
                            obscure: controller.obscurePass,
                            onToggle: controller.toggleObscurePass,
                          ),
                          _PasswordRegField(
                            title: S.of(context).retypePassword,
                            controller: controller.confirmPassController,
                            isError: controller.confirmPassError,
                            obscure: controller.obscureConfirm,
                            onToggle: controller.toggleObscureConfirm,
                          ),
                          const SizedBox(height: 30),
                          TextButtonCustom(
                            onPressed: controller.onCreateAccountClick,
                            title: S.of(context).register,
                            titleColor: ColorRes.darkSkyBlue,
                            backgroundColor:
                                ColorRes.darkSkyBlue.withValues(alpha: 0.2),
                          ),
                        ],

                        const SizedBox(height: 20),
                        const PolicyText(),
                        SizedBox(height: AppBar().preferredSize.height / 3),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Step indicator ────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final done = i <= current;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            height: 4,
            decoration: BoxDecoration(
              color: done ? ColorRes.havelockBlue : ColorRes.havelockBlue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

// ── Text field ────────────────────────────────────────────────────────────────
class _RegField extends StatelessWidget {
  final String title;
  final String? hint;
  final TextEditingController controller;
  final bool isError;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int? maxLength;

  const _RegField({
    required this.title,
    required this.controller,
    this.hint,
    this.isError = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 7),
          child: Text(title,
              style: MyTextStyle.montserratRegular(
                  color: ColorRes.battleshipGrey, size: 16)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isError ? ColorRes.ferrariRed : ColorRes.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(1),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              textCapitalization: textCapitalization,
              maxLength: maxLength,
              decoration: InputDecoration(
                border: InputBorder.none,
                fillColor: ColorRes.aquaHaze,
                filled: true,
                counterText: '',
                hintText: hint,
                hintStyle: MyTextStyle.montserratRegular(
                    color: ColorRes.battleshipGrey, size: 13),
              ),
              cursorColor: ColorRes.darkJungleGreen,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Password field ────────────────────────────────────────────────────────────
class _PasswordRegField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final bool isError;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordRegField({
    required this.title,
    required this.controller,
    required this.obscure,
    required this.onToggle,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 7),
          child: Text(title,
              style: MyTextStyle.montserratRegular(
                  color: ColorRes.battleshipGrey, size: 16)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isError ? ColorRes.ferrariRed : ColorRes.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(1),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: TextField(
              controller: controller,
              obscureText: obscure,
              decoration: InputDecoration(
                border: InputBorder.none,
                fillColor: ColorRes.aquaHaze,
                filled: true,
                suffixIconConstraints: const BoxConstraints(),
                suffixIcon: InkWell(
                  onTap: onToggle,
                  child: Image.asset(
                    obscure ? AssetRes.ciHide : AssetRes.ciNotHide,
                    height: 20,
                    width: 30,
                    color: ColorRes.havelockBlue,
                  ),
                ),
              ),
              cursorColor: ColorRes.darkJungleGreen,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Phone field with country code picker ─────────────────────────────────────
class _PhoneFieldWithCode extends StatelessWidget {
  final TextEditingController controller;
  final String selectedCode;
  final ValueChanged<String> onCodeChanged;
  final bool isError;

  static const _codes = ['+970', '+972'];

  const _PhoneFieldWithCode({
    required this.controller,
    required this.selectedCode,
    required this.onCodeChanged,
    this.isError = false,
  });

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: ColorRes.havelockBlue.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'اختر مقدمة الدولة',
            style: MyTextStyle.montserratBold(size: 16, color: ColorRes.darkJungleGreen),
          ),
          const SizedBox(height: 8),
          ..._codes.map((code) => ListTile(
                onTap: () { onCodeChanged(code); Navigator.pop(context); },
                trailing: Text(code,
                    style: MyTextStyle.montserratBold(size: 16, color: ColorRes.darkJungleGreen)),
                title: Text(
                  code == '+970' ? 'فلسطين' : 'إسرائيل',
                  textAlign: TextAlign.right,
                  style: MyTextStyle.montserratRegular(size: 14, color: ColorRes.battleshipGrey),
                ),
                leading: selectedCode == code
                    ? Icon(Icons.check_circle_rounded, color: ColorRes.havelockBlue)
                    : Icon(Icons.radio_button_unchecked_rounded, color: ColorRes.battleshipGrey),
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isError ? ColorRes.ferrariRed : ColorRes.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Container(
          color: ColorRes.aquaHaze,
          child: Row(children: [
            GestureDetector(
              onTap: () => _showPicker(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(selectedCode,
                      style: MyTextStyle.montserratBold(size: 15, color: ColorRes.darkJungleGreen)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down_rounded, size: 20, color: ColorRes.battleshipGrey),
                ]),
              ),
            ),
            Container(width: 1, height: 28, color: ColorRes.battleshipGrey.withValues(alpha: 0.3)),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  hintText: 'xxxxxxxxxx',
                  hintStyle: MyTextStyle.montserratRegular(color: ColorRes.battleshipGrey, size: 13),
                ),
                cursorColor: ColorRes.darkJungleGreen,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Policy text ───────────────────────────────────────────────────────────────
class PolicyText extends StatelessWidget {
  const PolicyText({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: S.of(context).byProceedingForwardYouAgreeToThen,
          style: MyTextStyle.montserratRegular(
              size: 12, color: ColorRes.battleshipGrey),
          children: [
            TextSpan(
              text: S.of(context).privacyPolicy,
              style: MyTextStyle.montserratBold(
                  size: 12, color: ColorRes.charcoalGrey),
              recognizer: TapGestureRecognizer()
                ..onTap = () => CommonFun.loadUrl(url: ConstRes.privacyPolicy),
            ),
            TextSpan(
              text: ' ${S.of(context).and} ',
              style: MyTextStyle.montserratRegular(
                  size: 12, color: ColorRes.battleshipGrey),
            ),
            TextSpan(
              text: S.of(context).termsConditions,
              style: MyTextStyle.montserratBold(
                  size: 12, color: ColorRes.charcoalGrey),
              recognizer: TapGestureRecognizer()
                ..onTap = () => CommonFun.loadUrl(url: ConstRes.termsOfUse),
            ),
          ],
        ),
      ),
    );
  }
}
