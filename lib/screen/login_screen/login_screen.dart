import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/login_screen/login_screen_controller.dart';
import 'package:patient_flutter/utils/const_res.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const _primary = Color(0xFF00685d);
  static const _bg = Color(0xFFF6FAF8);
  static const _surface = Color(0xFFEAEFEC);
  static const _onSurface = Color(0xFF171D1B);
  static const _outline = Color(0xFF6D7A77);
  static const _outlineVariant = Color(0xFFBCC9C5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: GetBuilder<LoginScreenController>(
        init: LoginScreenController(),
        builder: (c) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),

                // ── Logo ─────────────────────────────────────────────────
                Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          appName,
                          style: const TextStyle(
                            fontFamily: 'ProductSans-Bold',
                            fontSize: 28,
                            color: _primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: _primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ── Heading ───────────────────────────────────────────────
                const Text(
                  'أهلاً بك مجدداً',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'ProductSans-Bold',
                    fontSize: 26,
                    color: _onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'سجل دخولك لمتابعة خطتك العلاجية',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'ProductSans-Regular',
                    fontSize: 14,
                    color: _outline,
                  ),
                ),

                const SizedBox(height: 36),

                // ── Phone ─────────────────────────────────────────────────
                const _FieldLabel(text: 'رقم الهاتف'),
                const SizedBox(height: 8),
                _PhoneField(
                  controller: c.phoneController,
                  selectedCode: c.selectedCountryCode,
                  onCodeChanged: c.onCountryCodeChanged,
                ),
                const SizedBox(height: 20),

                // ── Password ──────────────────────────────────────────────
                const _FieldLabel(text: 'كلمة المرور'),
                const SizedBox(height: 8),
                _PasswordField(
                  controller: c.passwordController,
                  obscure: c.obscurePassword,
                  onToggle: c.togglePasswordVisibility,
                ),

                // ── Forgot password ───────────────────────────────────────
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () => c.onForgotPasswordTap(context),
                    child: const Text(
                      'نسيت كلمة المرور؟',
                      style: TextStyle(
                        fontFamily: 'ProductSans-Medium',
                        fontSize: 14,
                        color: _primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ── Login button ──────────────────────────────────────────
                _GradientButton(
                  label: 'تسجيل الدخول',
                  onTap: c.onLoginClick,
                ),

                const SizedBox(height: 24),

                // ── Register ──────────────────────────────────────────────
                GestureDetector(
                  onTap: c.onRegisterTap,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      text: 'ليس لديك حساب؟  ',
                      style: TextStyle(
                        fontFamily: 'ProductSans-Regular',
                        fontSize: 14,
                        color: _outline,
                      ),
                      children: [
                        TextSpan(
                          text: 'إنشاء حساب جديد',
                          style: TextStyle(
                            fontFamily: 'ProductSans-Bold',
                            fontSize: 14,
                            color: _primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Divider ───────────────────────────────────────────────
                const Row(
                  children: [
                    Expanded(child: Divider(color: _outlineVariant)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'أو سجل دخولك عبر',
                        style: TextStyle(
                          fontFamily: 'ProductSans-Regular',
                          fontSize: 12,
                          color: _outline,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: _outlineVariant)),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Social buttons ────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _SocialBtn(
                          label: 'جوجل', icon: Icons.g_mobiledata_rounded),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SocialBtn(
                          label: 'أبل iOS', icon: Icons.apple_rounded),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // ── Footer ────────────────────────────────────────────────
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  children: [
                    _fIcon(Icons.medical_services_outlined),
                    _fIcon(Icons.verified_user_outlined),
                    _fIcon(Icons.check_circle_outline_rounded),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'جميع الحقوق محفوظة لـ $appName ${DateTime.now().year}',
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: const TextStyle(
                    fontFamily: 'ProductSans-Regular',
                    fontSize: 11,
                    color: _outline,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _fIcon(IconData i) =>
      Icon(i, size: 22, color: Color(0xFF00685d).withValues(alpha: .5));
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});
  @override
  Widget build(BuildContext context) => Text(
        text,
        textAlign: TextAlign.end,
        style: const TextStyle(
          fontFamily: 'ProductSans-Medium',
          fontSize: 13,
          color: Color(0xFF3D4946),
        ),
      );
}

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String selectedCode;
  final ValueChanged<String> onCodeChanged;
  const _PhoneField({
    required this.controller,
    required this.selectedCode,
    required this.onCodeChanged,
  });

  static const _codes = ['+970', '+972'];
  static const _primary = Color(0xFF00685d);

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
              color: const Color(0xFFBCC9C5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'اختر مقدمة الدولة',
            style: TextStyle(
              fontFamily: 'ProductSans-Bold',
              fontSize: 16,
              color: Color(0xFF171D1B),
            ),
          ),
          const SizedBox(height: 8),
          ..._codes.map((code) => ListTile(
                onTap: () {
                  onCodeChanged(code);
                  Navigator.pop(context);
                },
                trailing: Text(
                  code,
                  style: const TextStyle(
                    fontFamily: 'ProductSans-Bold',
                    fontSize: 16,
                    color: Color(0xFF171D1B),
                  ),
                ),
                title: Text(
                  code == '+970' ? 'فلسطين' : 'إسرائيل',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'ProductSans-Regular',
                    fontSize: 14,
                    color: Color(0xFF6D7A77),
                  ),
                ),
                leading: selectedCode == code
                    ? const Icon(Icons.check_circle_rounded, color: _primary)
                    : const Icon(Icons.radio_button_unchecked_rounded,
                        color: Color(0xFFBCC9C5)),
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEAEFEC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Country code selector
          GestureDetector(
            onTap: () => _showPicker(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedCode,
                    style: const TextStyle(
                      fontFamily: 'ProductSans-Bold',
                      fontSize: 15,
                      color: Color(0xFF171D1B),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down_rounded,
                      size: 20, color: Color(0xFF6D7A77)),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 28, color: const Color(0xFFBCC9C5)),
          // Input
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.right,
              textDirection: TextDirection.ltr,
              onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                hintText: 'xxxxxxxxxx',
                hintStyle: TextStyle(
                  color: Color(0xFFBCC9C5),
                  fontFamily: 'ProductSans-Regular',
                  fontSize: 14,
                ),
                suffixIcon: Icon(Icons.phone_iphone_rounded,
                    size: 18, color: Color(0xFF6D7A77)),
              ),
              style: const TextStyle(
                fontFamily: 'ProductSans-Regular',
                color: Color(0xFF171D1B),
                fontSize: 15,
              ),
              cursorColor: Color(0xFF00685d),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  const _PasswordField(
      {required this.controller,
      required this.obscure,
      required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEAEFEC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.lock_outline_rounded,
              size: 18, color: Color(0xFF6D7A77)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              textAlign: TextAlign.right,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                hintText: '••••••••',
                hintStyle: const TextStyle(
                  color: Color(0xFFBCC9C5),
                  fontFamily: 'ProductSans-Regular',
                  fontSize: 14,
                ),
                suffixIcon: GestureDetector(
                  onTap: onToggle,
                  child: Icon(
                    obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                    color: const Color(0xFF6D7A77),
                  ),
                ),
              ),
              style: const TextStyle(
                fontFamily: 'ProductSans-Regular',
                color: Color(0xFF171D1B),
                fontSize: 15,
              ),
              cursorColor: const Color(0xFF00685d),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GradientButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF008376), Color(0xFF00685d)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00685d).withValues(alpha: .3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'ProductSans-Bold',
            fontSize: 16,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SocialBtn({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBCC9C5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: const Color(0xFF3D4946)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'ProductSans-Medium',
                fontSize: 14,
                color: Color(0xFF3D4946),
              ),
            ),
          ],
        ),
      );
}
