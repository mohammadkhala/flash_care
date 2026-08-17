import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/fcm_service.dart';
import '../../../../core/theme/app_theme.dart';

class OtpPage extends StatefulWidget {
  /// Passed as "countryCode phone"  e.g. "+972 599123456"
  final String phone;
  const OtpPage({required this.phone, super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  late final String _countryCode;
  late final String _phoneNumber;

  final List<TextEditingController> _ctrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());

  bool _loading   = false;
  bool _resending = false;
  int  _seconds   = AppConstants.otpResendSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Parse "code phone"
    final parts = widget.phone.split(' ');
    _countryCode = parts.isNotEmpty ? parts[0] : AppConstants.defaultCountryCode;
    _phoneNumber = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _nodes[0].requestFocus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _ctrls)  c.dispose();
    for (final f in _nodes) f.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = AppConstants.otpResendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _seconds--;
        if (_seconds <= 0) t.cancel();
      });
    });
  }

  String get _otp => _ctrls.map((c) => c.text).join();

  // ── Verify ────────────────────────────────────────────────────────────────
  Future<void> _verify() async {
    if (_otp.length < 6) { _err('أدخل رمز التحقق كاملاً'); return; }
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.post('/auth/verify-otp', data: {
        'phone':              _phoneNumber,
        'phone_country_code': _countryCode,
        'otp':                _otp,
      });

      final data  = res.data as Map<String, dynamic>;
      final token = data['token'] as String?;
      if (token != null) {
        await ApiClient.setToken(token);
        unawaited(FcmService.instance.refreshToken());
      }
      if (!mounted) return;

      if (data['needs_password'] == true) {
        context.go('/auth/set-password', extra: {
          'needsProfile': data['needs_profile'] ?? true,
        });
      } else if (data['needs_profile'] == true) {
        context.go('/auth/setup');
      } else {
        context.go('/home');
      }
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?
          ?? 'رمز التحقق غير صحيح';
      _err(msg);
      // Clear boxes
      for (final c in _ctrls) c.clear();
      _nodes[0].requestFocus();
    } catch (e) {
      _err('حدث خطأ: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Resend ────────────────────────────────────────────────────────────────
  Future<void> _resend() async {
    if (_seconds > 0 || _resending) return;
    setState(() => _resending = true);
    try {
      await ApiClient.instance.post('/auth/send-otp', data: {
        'phone':              _phoneNumber,
        'phone_country_code': _countryCode,
        'type':               'patient',
      });
      if (!mounted) return;
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('تم إعادة إرسال رمز التحقق عبر واتساب'),
      ));
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?
          ?? 'تعذّر إعادة الإرسال';
      _err(msg);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  void _err(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m), backgroundColor: AppColors.error));

  void _onChanged(String val, int i) {
    if (val.isNotEmpty && i < 5) _nodes[i + 1].requestFocus();
    if (val.isEmpty   && i > 0) _nodes[i - 1].requestFocus();
    if (_otp.length == 6) _verify();
  }

  @override
  Widget build(BuildContext context) {
    final maskedPhone =
        '$_countryCode ***${_phoneNumber.length > 4 ? _phoneNumber.substring(_phoneNumber.length - 4) : _phoneNumber}';

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/auth/register')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),

            // ── Icon ───────────────────────────────────────────────────
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: const Color(0x1F1B2E6E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.sms_outlined,
                  color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 20),

            Text('التحقق من الهاتف',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 10),
            Text(
              'أرسلنا رمز التحقق إلى\n$maskedPhone عبر واتساب',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),

            // ── OTP Boxes ─────────────────────────────────────────────
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: SizedBox(
                    width: 46, height: 56,
                    child: TextField(
                      controller: _ctrls[i],
                      focusNode: _nodes[i],
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 2),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (v) => _onChanged(v, i),
                    ),
                  ),
                )),
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _loading ? null : _verify,
              child: _loading
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('تحقق'),
            ),

            const SizedBox(height: 24),

            // ── Resend ─────────────────────────────────────────────────
            if (_seconds > 0)
              Text(
                'إعادة الإرسال بعد $_seconds ثانية',
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontFamily: 'Cairo'),
              )
            else
              TextButton(
                onPressed: _resending ? null : _resend,
                child: _resending
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text(
                        'إعادة إرسال الرمز',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Cairo'),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
