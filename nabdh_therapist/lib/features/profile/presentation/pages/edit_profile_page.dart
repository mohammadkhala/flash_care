import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _name    = TextEditingController();
  final _title   = TextEditingController();
  final _bio     = TextEditingController();
  final _city    = TextEditingController();
  final _exp     = TextEditingController();
  String _gender = 'male';
  File? _avatar;
  bool _loading = true, _saving = false;

  static const _cities = ['رام الله','نابلس','الخليل','بيت لحم','جنين','طولكرم','قلقيلية','أريحا','سلفيت','طوباس','القدس','غزة','خانيونس','رفح','غيره'];

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _name.dispose(); _title.dispose(); _bio.dispose(); _city.dispose(); _exp.dispose(); super.dispose(); }

  Future<void> _load() async {
    try {
      final res = await ApiClient.instance.get('/therapist/profile');
      final t = res.data['therapist'] as Map? ?? res.data as Map;
      _name.text  = t['full_name'] ?? '';
      _title.text = t['title']    ?? '';
      _bio.text   = t['bio']      ?? '';
      _city.text  = t['city']     ?? '';
      _exp.text   = '${t['years_experience'] ?? 0}';
      _gender     = t['gender']   ?? 'male';
      setState(() => _loading = false);
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _pickAvatar() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 800);
    if (img != null) setState(() => _avatar = File(img.path));
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل الاسم الكامل')));
      return;
    }
    setState(() => _saving = true);
    try {
      if (_avatar != null) {
        await ApiClient.multipartPost('/therapist/profile/avatar', _avatar!.path, 'avatar');
      }
      await ApiClient.instance.put('/therapist/profile', data: {
        'full_name':        _name.text.trim(),
        'title':            _title.text.trim(),
        'bio':              _bio.text.trim(),
        'city':             _city.text.trim(),
        'years_experience': int.tryParse(_exp.text) ?? 0,
        'gender':           _gender,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ ✓')));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.error));
    } finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('تعديل الملف الشخصي'),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('حفظ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Avatar
        Center(child: GestureDetector(
          onTap: _pickAvatar,
          child: Stack(children: [
            CircleAvatar(radius: 52, backgroundColor: AppColors.border,
              backgroundImage: _avatar != null ? FileImage(_avatar!) : null,
              child: _avatar == null ? const Icon(Icons.person, size: 48, color: AppColors.textSecondary) : null),
            Positioned(bottom: 0, right: 0, child: Container(
              padding: const EdgeInsets.all(7),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
            )),
          ]),
        )),
        const SizedBox(height: 24),

        _lbl('الاسم الكامل *'),
        TextField(controller: _name, decoration: const InputDecoration(hintText: 'الاسم الكامل')),
        const SizedBox(height: 16),

        _lbl('اللقب المهني'),
        TextField(controller: _title, decoration: const InputDecoration(hintText: 'مثال: أخصائي علاج طبيعي')),
        const SizedBox(height: 16),

        _lbl('الجنس'),
        Row(children: [
          Expanded(child: _genderOpt('male', 'ذكر', Icons.male)),
          const SizedBox(width: 12),
          Expanded(child: _genderOpt('female', 'أنثى', Icons.female)),
        ]),
        const SizedBox(height: 16),

        _lbl('المدينة'),
        DropdownButtonFormField<String>(
          value: _cities.contains(_city.text) ? _city.text : null,
          hint: const Text('اختر المدينة'),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            filled: true, fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) { if (v != null) _city.text = v; },
        ),
        const SizedBox(height: 16),

        _lbl('سنوات الخبرة'),
        TextField(controller: _exp, keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(suffixText: 'سنة')),
        const SizedBox(height: 16),

        _lbl('نبذة شخصية'),
        TextField(controller: _bio, maxLines: 4, maxLength: 500,
            decoration: const InputDecoration(hintText: 'اكتب نبذة عن نفسك...')),
        const SizedBox(height: 40),
      ])),
    );
  }

  Widget _lbl(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)));

  Widget _genderOpt(String val, String lbl, IconData icon) {
    final sel = _gender == val;
    return GestureDetector(
      onTap: () => setState(() => _gender = val),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: sel ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: sel ? AppColors.primary : AppColors.border),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: sel ? Colors.white : AppColors.textSecondary, size: 20),
          const SizedBox(width: 6),
          Text(lbl, style: TextStyle(color: sel ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
