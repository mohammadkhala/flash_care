import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/fcm_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/country_code_picker.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController    = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedCode      = AppConstants.defaultCountryCode;
  bool _isLoading           = false;
  bool _obscurePassword     = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final phone    = _phoneController.text.trim();
    final password = _passwordController.text;

    if (phone.length < 9) { _showError('أدخل رقم هاتف صحيح'); return; }
    if (password.length < 6) { _showError('كلمة المرور قصيرة جداً'); return; }

    setState(() => _isLoading = true);
    try {
      final res = await ApiClient.instance.post('/auth/login', data: {
        'phone':              phone,
        'phone_country_code': _selectedCode,
        'password':           password,
        'type':               'therapist',
      });

      await ApiClient.setToken(res.data['token']); // triggers AuthNotifier → GoRouter redirects
      unawaited(FcmService.instance.refreshToken());
      if (!mounted) return;

      if (res.data['needs_profile'] == true) {
        context.go('/auth/setup');
      } else if (res.data['is_approved'] == false) {
        // Keep the token so the pending page can poll /me for approval.
        context.go('/auth/pending');
      }
      // else: GoRouter redirect handles /home automatically via AuthNotifier.notify()
    } on DioException catch (e) {
      String msg = 'رقم الهاتف أو كلمة المرور غير صحيحة';
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        msg = 'تعذّر الاتصال بالخادم (timeout)';
      } else if (e.type == DioExceptionType.connectionError) {
        msg = 'لا يمكن الوصول للخادم: ${e.message}';
      } else if (e.response != null) {
        final data = e.response!.data;
        if (data is Map) {
          final errors = data['errors'];
          if (errors is Map && errors.isNotEmpty) {
            msg = errors.values.first is List
                ? errors.values.first.first.toString()
                : errors.values.first.toString();
          } else if (data['message'] != null) {
            msg = data['message'].toString();
          }
        }
      }
      _showError(msg);
    } catch (e) {
      _showError('خطأ: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.error,
    ));
  }

  Future<void> _showForgotPassword(BuildContext context) async {
    final phoneCtrl = TextEditingController(text: _phoneController.text);
    String code     = _selectedCode;
    bool   sending  = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24,
            MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('استرجاع كلمة المرور',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
          const SizedBox(height: 6),
          const Text('سيُرسل لك رمز تحقق عبر واتساب',
              style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Cairo', fontSize: 13)),
          const SizedBox(height: 20),
          _PhoneField(
            controller: phoneCtrl,
            selectedCode: code,
            onCodeChanged: (c) => set(() => code = c),
          ),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.chat_rounded, color: Colors.white, size: 20),
              label: sending
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('إرسال رمز التحقق', style: TextStyle(fontFamily: 'Cairo')),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
              onPressed: sending ? null : () async {
                final phone = phoneCtrl.text.trim();
                if (phone.length < 9) return;
                set(() => sending = true);
                try {
                  await ApiClient.instance.post('/auth/forgot-password', data: {
                    'phone': phone, 'phone_country_code': code, 'type': 'therapist',
                  });
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  context.push('/auth/otp', extra: '$code $phone');
                } catch (e) {
                  set(() => sending = false);
                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('الرقم غير مسجل أو حدث خطأ')));
                }
              },
            ),
          ),
        ]),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/auth')),
        title: const Text('تسجيل الدخول'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text('أهلاً بعودتك', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            const Text(
              'أدِر جلساتك العلاجية باحترافية وتواصل مع مرضاك',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontFamily: 'Cairo',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Text('أدخل رقم هاتفك وكلمة المرور', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 32),

            // Phone field
            Text('رقم الهاتف', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
            const SizedBox(height: 8),
            _PhoneField(
              controller: _phoneController,
              selectedCode: _selectedCode,
              onCodeChanged: (c) => setState(() => _selectedCode = c),
            ),

            const SizedBox(height: 20),

            // Password field
            Text('كلمة المرور', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: '••••••••',
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('دخول'),
            ),

            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: () => _showForgotPassword(context),
                icon: const Icon(Icons.chat_rounded, color: Color(0xFF25D366), size: 18),
                label: const Text(
                  'نسيت كلمة المرور؟ استرجاع عبر واتساب',
                  style: TextStyle(fontFamily: 'Cairo', color: Color(0xFF25D366)),
                ),
              ),
            ),

            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: () => context.go('/auth/register'),
                child: const Text('ليس لديك حساب؟ إنشاء حساب جديد'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String selectedCode;
  final ValueChanged<String> onCodeChanged;

  const _PhoneField({required this.controller, required this.selectedCode, required this.onCodeChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              final picked = await showCountryCodePicker(context, selected: selectedCode);
              if (picked != null) onCodeChanged(picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(border: Border(right: BorderSide(color: AppColors.border))),
              child: Row(children: [
                Text(selectedCode, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 20, color: AppColors.textSecondary),
              ]),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                hintText: '5XXXXXXXX',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                hintStyle: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
