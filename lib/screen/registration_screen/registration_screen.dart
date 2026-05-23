import 'package:doctor_flutter/common/common_fun.dart';
import 'package:doctor_flutter/common/text_button_custom.dart';
import 'package:doctor_flutter/common/top_bar_area.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/screen/registration_screen/registration_screen_controller.dart';
import 'package:doctor_flutter/utils/asset_res.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/const_res.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                          const Text(
                            'أدخل رقم واتساب الخاص بك لاستقبال رمز التحقق.',
                            style: TextStyle(
                                color: ColorRes.battleshipGrey,
                                fontFamily: FontRes.regular),
                          ),
                          const SizedBox(height: 30),
                          _RegField(
                            title: 'رقم هاتف واتساب',
                            hint: 'e.g. +966512345678',
                            controller: controller.phoneController,
                            isError: controller.phoneError,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 30),
                          TextButtonCustom(
                            onPressed: controller.onSendOtpClick,
                            title: 'إرسال رمز التحقق عبر واتساب',
                            titleColor: ColorRes.havelockBlue,
                            backgroundColor:
                                ColorRes.havelockBlue.withValues(alpha: 0.2),
                          ),
                        ],

                        // ── Step 1: OTP ─────────────────────────────────
                        if (controller.step == 1) ...[
                          const Text(
                            'أدخل الرمز المكوّن من 6 أرقام الذي أُرسل إلى واتساب.',
                            style: TextStyle(
                                color: ColorRes.battleshipGrey,
                                fontFamily: FontRes.regular),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            controller.phoneController.text,
                            style: const TextStyle(
                                color: ColorRes.havelockBlue,
                                fontFamily: FontRes.semiBold),
                          ),
                          const SizedBox(height: 30),
                          _RegField(
                            title: 'رمز التحقق (OTP)',
                            hint: '000000',
                            controller: controller.otpController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                          ),
                          const SizedBox(height: 30),
                          TextButtonCustom(
                            onPressed: controller.onVerifyOtpClick,
                            title: 'تحقق من رقم الهاتف',
                            titleColor: ColorRes.havelockBlue,
                            backgroundColor:
                                ColorRes.havelockBlue.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: InkWell(
                              onTap: controller.onResendOtp,
                              child: const Text(
                                'إعادة إرسال الرمز',
                                style: TextStyle(
                                    color: ColorRes.havelockBlue,
                                    fontFamily: FontRes.regular,
                                    fontSize: 15),
                              ),
                            ),
                          ),
                        ],

                        // ── Step 2: name + password ─────────────────────
                        if (controller.step == 2) ...[
                          const Text(
                            'أكمل بيانات حسابك.',
                            style: TextStyle(
                                color: ColorRes.battleshipGrey,
                                fontFamily: FontRes.regular),
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
                            titleColor: ColorRes.havelockBlue,
                            backgroundColor:
                                ColorRes.havelockBlue.withValues(alpha: 0.2),
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
              color: done
                  ? ColorRes.havelockBlue
                  : ColorRes.havelockBlue.withValues(alpha: 0.2),
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
              style: const TextStyle(
                  color: ColorRes.battleshipGrey,
                  fontSize: 16,
                  fontFamily: FontRes.regular)),
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
                hintStyle: const TextStyle(
                    color: ColorRes.battleshipGrey,
                    fontFamily: FontRes.regular,
                    fontSize: 13),
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
              style: const TextStyle(
                  color: ColorRes.battleshipGrey,
                  fontSize: 16,
                  fontFamily: FontRes.regular)),
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
                    height: 25,
                    width: 35,
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

// ── Policy text ───────────────────────────────────────────────────────────────
class PolicyText extends StatelessWidget {
  const PolicyText({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: S.of(context).byProceedingForwardYouAgreeToThen,
          style: const TextStyle(
              fontFamily: FontRes.regular,
              fontSize: 12,
              color: ColorRes.battleshipGrey),
          children: [
            TextSpan(
              text: S.of(context).privacyPolicy,
              style: const TextStyle(
                  fontFamily: FontRes.semiBold,
                  fontSize: 12,
                  color: ColorRes.charcoalGrey),
              recognizer: TapGestureRecognizer()
                ..onTap = () => CommonFun.loadUrl(url: ConstRes.privacyPolicy),
            ),
            TextSpan(
              text: ' ${S.of(context).and} ',
              style: const TextStyle(
                  fontFamily: FontRes.regular,
                  fontSize: 12,
                  color: ColorRes.battleshipGrey),
            ),
            TextSpan(
              text: S.of(context).termsConditions,
              style: const TextStyle(
                  fontFamily: FontRes.semiBold,
                  fontSize: 12,
                  color: ColorRes.charcoalGrey),
              recognizer: TapGestureRecognizer()
                ..onTap = () => CommonFun.loadUrl(url: ConstRes.termsOfUser),
            ),
          ],
        ),
      ),
    );
  }
}
