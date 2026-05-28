import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';

/// Registration page — sends OTP to new patient's phone number
class PhoneInputPage extends StatefulWidget {
  const PhoneInputPage({super.key});

  @override
  State<PhoneInputPage> createState() => _PhoneInputPageState();
}

class _PhoneInputPageState extends State<PhoneInputPage> {
  final _phoneCtrl = TextEditingController();
  String _code     = AppConstants.defaultCountryCode;
  bool   _loading  = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.length < 9) {
      _err('أدخل رقم هاتف صحيح (9 أرقام على الأقل)');
      return;
    }

    setState(() => _loading = true);
    try {
      await ApiClient.instance.post('/auth/send-otp', data: {
        'phone':              phone,
        'phone_country_code': _code,
        'type':               'patient',
      });

      if (!mounted) return;
      // Pass phone as "code phone" (space-separated)
      context.push('/auth/otp', extra: '$_code $phone');

    } on DioException catch (e) {
      if (!mounted) return;

      final data = e.response?.data;

      // Already registered → go to login
      if (e.response?.statusCode == 422 &&
          data is Map && data['already_registered'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('هذا الرقم مسجّل مسبقاً — سيتم توجيهك لتسجيل الدخول'),
          backgroundColor: Colors.orange,
        ));
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) context.go('/auth/login');
        return;
      }

      // Connection errors
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        _err('لا يمكن الاتصال بالخادم، تحقق من الاتصال بالشبكة');
        return;
      }

      // Other API errors
      String msg = 'تعذّر إرسال رمز التحقق';
      if (data is Map) {
        if (data['message'] != null) msg = data['message'].toString();
        if (data['errors'] is Map) {
          final errors = data['errors'] as Map;
          if (errors.isNotEmpty) {
            final first = errors.values.first;
            msg = first is List ? first.first.toString() : first.toString();
          }
        }
      }
      _err(msg);

    } catch (e) {
      _err('حدث خطأ غير متوقع: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _err(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m), backgroundColor: AppColors.error));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/auth')),
        title: const Text('إنشاء حساب جديد'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            Text('مرحباً بك 👋',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'أدخل رقم هاتفك لاستلام رمز التحقق عبر واتساب',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),

            const _FieldLabel('رقم الهاتف'),
            const SizedBox(height: 8),
            _PhoneField(
              ctrl: _phoneCtrl,
              code: _code,
              onCode: (c) => setState(() => _code = c),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _loading ? null : _sendOtp,
              child: _loading
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('إرسال رمز التحقق'),
            ),

            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () => context.go('/auth/login'),
                child: const Text(
                  'لديك حساب بالفعل؟ تسجيل الدخول',
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Center(
              child: Text(
                'بالمتابعة توافق على شروط الاستخدام وسياسة الخصوصية',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 12,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Phone field ────────────────────────────────────────────────────────────
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
                  border:
                      Border(right: BorderSide(color: AppColors.border))),
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
              onSubmitted: (_) {},
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

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
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
