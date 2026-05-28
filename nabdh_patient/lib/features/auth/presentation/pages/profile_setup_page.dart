import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _nameCtrl = TextEditingController();
  String  _gender = 'male';
  String? _city;
  bool _loading   = false;

  static const _cities = [
    'رام الله', 'نابلس', 'الخليل', 'بيت لحم', 'جنين',
    'طولكرم', 'قلقيلية', 'أريحا', 'سلفيت', 'طوباس',
    'القدس', 'غزة', 'خانيونس', 'رفح', 'غيره',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.length < 3) { _err('أدخل الاسم الكامل (3 أحرف على الأقل)'); return; }
    if (_city == null)   { _err('اختر مدينتك'); return; }

    setState(() => _loading = true);
    try {
      await ApiClient.instance.post('/patient/profile/complete', data: {
        'full_name': name,
        'gender':    _gender,
        'city':      _city,
      });
      if (!mounted) return;
      context.go('/home');
    } on DioException catch (e) {
      String msg = 'حدث خطأ، حاول مجدداً';
      final data = e.response?.data;
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
      _err('حدث خطأ غير متوقع');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _err(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m), backgroundColor: AppColors.error));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: AppColors.surface,
              child: Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('N',
                        style: TextStyle(
                            color: Colors.white, fontSize: 18,
                            fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('إكمال الملف الشخصي',
                          style: Theme.of(context).textTheme.titleMedium),
                      Text('خطوة أخيرة لبدء الاستخدام',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ]),
            ),

            // ── Form ──────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Avatar placeholder
                    Center(
                      child: Container(
                        width: 88, height: 88,
                        decoration: const BoxDecoration(
                          color: Color(0x1F1B2E6E),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_outline_rounded,
                            color: AppColors.primary, size: 44),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Name
                    const _Label('الاسم الكامل *'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration:
                          const InputDecoration(hintText: 'مثال: محمد أحمد'),
                    ),
                    const SizedBox(height: 20),

                    // Gender
                    const _Label('الجنس *'),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: _GenderBtn(
                        label: 'ذكر', icon: Icons.male_rounded,
                        selected: _gender == 'male',
                        onTap: () => setState(() => _gender = 'male'),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _GenderBtn(
                        label: 'أنثى', icon: Icons.female_rounded,
                        selected: _gender == 'female',
                        onTap: () => setState(() => _gender = 'female'),
                      )),
                    ]),
                    const SizedBox(height: 20),

                    // City
                    const _Label('المدينة *'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _city,
                      hint: const Text('اختر مدينتك',
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              color: AppColors.textHint)),
                      decoration: InputDecoration(
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
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      items: _cities
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c,
                                    style: const TextStyle(
                                        fontFamily: 'Cairo')),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _city = v),
                    ),

                    const SizedBox(height: 36),
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('ابدأ الاستخدام'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _GenderBtn({
    required this.label, required this.icon,
    required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.border),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon,
                color: selected ? Colors.white : AppColors.textSecondary,
                size: 20),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: selected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo')),
          ]),
        ),
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
