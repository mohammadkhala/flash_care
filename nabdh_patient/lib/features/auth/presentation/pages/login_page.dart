import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/fcm_service.dart';
import '../../../../core/theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _code        = AppConstants.defaultCountryCode;
  bool   _loading     = false;
  bool   _obscure     = true;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final phone = _phoneCtrl.text.trim();
    final pass  = _passwordCtrl.text;
    if (phone.length < 9) { _err('أدخل رقم هاتف صحيح'); return; }
    if (pass.length < 6)  { _err('كلمة المرور قصيرة جداً'); return; }

    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.post('/auth/login', data: {
        'phone':              phone,
        'phone_country_code': _code,
        'password':           pass,
        'type':               'patient',
      });

      await ApiClient.setToken(res.data['token']);
      unawaited(FcmService.instance.refreshToken());
      if (!mounted) return;

      if (res.data['needs_profile'] == true) {
        context.go('/auth/setup');
      } else {
        context.go('/home');
      }
    } on DioException catch (e) {
      String msg = 'رقم الهاتف أو كلمة المرور غير صحيحة';
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        msg = 'لا يمكن الاتصال بالخادم، تحقق من الاتصال';
      } else if (e.response != null) {
        final data = e.response!.data;
        if (data is Map) {
          final errors = data['errors'];
          if (errors is Map && errors.isNotEmpty) {
            final first = errors.values.first;
            msg = first is List ? first.first.toString() : first.toString();
          } else if (data['message'] != null) {
            msg = data['message'].toString();
          }
        }
      }
      _err(msg);
    } catch (e) {
      _err('حدث خطأ: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _err(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m), backgroundColor: AppColors.error));

  Future<void> _showForgotPassword(BuildContext context) async {
    final phoneCtrl = TextEditingController(text: _phoneCtrl.text);
    String code     = _code;
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
          _PhoneField(ctrl: phoneCtrl, code: code, onCode: (c) => set(() => code = c)),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.whatsapp, color: Colors.white, size: 20),
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
                    'phone': phone, 'phone_country_code': code, 'type': 'patient',
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
            const SizedBox(height: 12),

            Text('أهلاً بعودتك 👋',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('أدخل رقم هاتفك وكلمة المرور',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 32),

            // ── Phone ─────────────────────────────────────────────────
            const _Label('رقم الهاتف'),
            const SizedBox(height: 8),
            _PhoneField(
              ctrl: _phoneCtrl,
              code: _code,
              onCode: (c) => setState(() => _code = c),
            ),
            const SizedBox(height: 20),

            // ── Password ──────────────────────────────────────────────
            const _Label('كلمة المرور'),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordCtrl,
              obscureText: _obscure,
              onSubmitted: (_) => _login(),
              decoration: InputDecoration(
                hintText: '••••••••',
                suffixIcon: IconButton(
                  icon: Icon(_obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('دخول'),
            ),

            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: () => _showForgotPassword(context),
                icon: const Icon(Icons.whatsapp, color: Color(0xFF25D366), size: 18),
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
                child: const Text(
                  'ليس لديك حساب؟ إنشاء حساب جديد',
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared phone field widget ─────────────────────────────────────────────
class _PhoneField extends StatelessWidget {
  final TextEditingController ctrl;
  final String code;
  final ValueChanged<String> onCode;
  const _PhoneField(
      {required this.ctrl, required this.code, required this.onCode});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          GestureDetector(
            onTap: () => showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20))),
              builder: (_) => ListView(
                shrinkWrap: true,
                children: AppConstants.countryCodes
                    .map((c) => ListTile(
                          title: Text(c,
                              style: const TextStyle(fontFamily: 'Cairo')),
                          selected: c == code,
                          selectedColor: AppColors.primary,
                          onTap: () {
                            onCode(c);
                            Navigator.pop(context);
                          },
                        ))
                    .toList(),
              ),
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: const BoxDecoration(
                  border: Border(
                      right: BorderSide(color: AppColors.border))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(code,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        fontFamily: 'Cairo')),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down,
                    size: 18, color: AppColors.textSecondary),
              ]),
            ),
          ),
          Expanded(
            child: TextField(
              controller: ctrl,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                hintText: '5XXXXXXXX',
                border: InputBorder.none,
                filled: false,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              ),
            ),
          ),
        ]),
      );
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            fontFamily: 'Cairo',
            color: AppColors.textPrimary),
      );
}
