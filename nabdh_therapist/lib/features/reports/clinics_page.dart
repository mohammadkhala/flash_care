import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../finance/finance_utils.dart';

/// The therapist's clinics: shown as "Institution" on reports, with the logo
/// and contact details used for the report letterhead.
class ClinicsPage extends StatefulWidget {
  const ClinicsPage({super.key});
  @override
  State<ClinicsPage> createState() => _ClinicsPageState();
}

class _ClinicsPageState extends State<ClinicsPage> {
  List<Map> _clinics = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient.instance.get('/therapist/clinics');
      setState(() {
        _clinics = (res.data as List).cast<Map>();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _edit([Map? clinic]) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ClinicForm(clinic: clinic),
    );
    if (saved == true) _load();
  }

  Future<void> _pickLogo(Map clinic) async {
    final f = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 90);
    if (f == null) return;
    try {
      await ApiClient.instance.post('/therapist/clinics/${clinic['id']}/logo',
          data: FormData.fromMap({'logo': await MultipartFile.fromFile(f.path, filename: f.name)}));
      _load();
      _snack('تم حفظ الشعار ✓');
    } catch (e) {
      _snack(apiError(e));
    }
  }

  Future<void> _removeLogo(Map clinic) async {
    try {
      await ApiClient.instance.delete('/therapist/clinics/${clinic['id']}/logo');
      _load();
    } catch (e) {
      _snack(apiError(e));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('عياداتي')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _edit(),
          icon: const Icon(Icons.add_business_outlined),
          label: const Text('عيادة جديدة'),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'ترويسة التقارير: الاسم بالإنجليزي على اليسار، الشعار في الوسط، الاسم بالعربي على اليمين، والعنوان والهاتف والبريد في سطر تحتها.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_clinics.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: Center(child: Text('لا توجد عيادات بعد — أضف عيادتك',
                            style: TextStyle(color: AppColors.textSecondary))),
                      ),
                    ..._clinics.map(_card),
                  ],
                ),
              ),
      );

  Widget _card(Map c) {
    final logo = c['logo_url'] as String?;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 72, height: 56,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: logo != null
                ? CachedNetworkImage(imageUrl: logo, fit: BoxFit.contain)
                : const Icon(Icons.local_hospital_outlined, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${c['name']}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            if ((c['name_en'] ?? '').toString().isNotEmpty)
              Text('${c['name_en']}', textDirection: TextDirection.ltr,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            if ('${c['address'] ?? ''}${c['city'] ?? ''}'.trim().isNotEmpty)
              Text([c['address'], c['city']].where((v) => (v ?? '').toString().isNotEmpty).join('، '),
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            if ((c['phone'] ?? '').toString().isNotEmpty)
              Text('${c['phone']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ])),
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _edit(c)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          TextButton.icon(
            onPressed: () => _pickLogo(c),
            icon: const Icon(Icons.image_outlined, size: 18),
            label: Text(logo == null ? 'إضافة شعار' : 'تغيير الشعار'),
          ),
          if (logo != null)
            TextButton(
              onPressed: () => _removeLogo(c),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('حذف الشعار'),
            ),
        ]),
      ]),
    );
  }
}

class _ClinicForm extends StatefulWidget {
  final Map? clinic;
  const _ClinicForm({this.clinic});
  @override
  State<_ClinicForm> createState() => _ClinicFormState();
}

class _ClinicFormState extends State<_ClinicForm> {
  late final _name = TextEditingController(text: widget.clinic?['name'] as String? ?? '');
  late final _address = TextEditingController(text: widget.clinic?['address'] as String? ?? '');
  late final _city = TextEditingController(text: widget.clinic?['city'] as String? ?? '');
  late final _phone = TextEditingController(text: widget.clinic?['phone'] as String? ?? '');
  late final _nameEn = TextEditingController(text: widget.clinic?['name_en'] as String? ?? '');
  late final _addressEn = TextEditingController(text: widget.clinic?['address_en'] as String? ?? '');
  late final _email = TextEditingController(text: widget.clinic?['email'] as String? ?? '');
  late final _website = TextEditingController(text: widget.clinic?['website'] as String? ?? '');
  late final _license = TextEditingController(text: widget.clinic?['license_number'] as String? ?? '');
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _address, _city, _phone, _nameEn, _addressEn, _email, _website, _license]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _opt(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final data = {
      'name': _name.text.trim(),
      'address': _address.text.trim(),
      'city': _city.text.trim(),
      'phone': _opt(_phone),
      'name_en': _opt(_nameEn),
      'address_en': _opt(_addressEn),
      'email': _opt(_email),
      'website': _opt(_website),
      'license_number': _opt(_license),
    };
    try {
      if (widget.clinic == null) {
        await ApiClient.instance.post('/therapist/clinics', data: data);
      } else {
        await ApiClient.instance.put('/therapist/clinics/${widget.clinic!['id']}', data: data);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiError(e))));
      setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف العيادة؟'),
        content: const Text('ستُزال من جدول المواعيد أيضاً.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('رجوع')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error), child: const Text('حذف')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _saving = true);
    try {
      await ApiClient.instance.delete('/therapist/clinics/${widget.clinic!['id']}');
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiError(e))));
      setState(() => _saving = false);
    }
  }

  InputDecoration _dec(String l, {String? hint}) => InputDecoration(
        labelText: l,
        hintText: hint,
        hintTextDirection: TextDirection.ltr,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  Widget _ltr(TextEditingController c, String label, String hint, {TextInputType? keyboard}) => TextField(
        controller: c,
        keyboardType: keyboard,
        textDirection: TextDirection.ltr,
        decoration: _dec(label, hint: hint),
      );

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(child: Text(widget.clinic == null ? 'عيادة جديدة' : 'تعديل العيادة',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
              if (widget.clinic != null)
                IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: _saving ? null : _delete),
            ]),
            const SizedBox(height: 12),
            TextField(controller: _name, decoration: _dec('اسم العيادة بالعربي (يمين الترويسة) *')),
            const SizedBox(height: 12),
            _ltr(_nameEn, 'اسم العيادة بالإنجليزي (يسار الترويسة)', 'Reloy Rehabilitation Center'),
            const SizedBox(height: 12),
            TextField(controller: _address, decoration: _dec('العنوان بالعربي')),
            const SizedBox(height: 12),
            TextField(controller: _city, decoration: _dec('المدينة')),
            const SizedBox(height: 12),
            _ltr(_addressEn, 'العنوان بالإنجليزي', 'Al-Irsal St., Ramallah'),
            const SizedBox(height: 12),
            TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: _dec('الهاتف')),
            const SizedBox(height: 12),
            _ltr(_email, 'البريد الإلكتروني (اختياري)', 'info@clinic.ps', keyboard: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _ltr(_website, 'الموقع الإلكتروني (اختياري)', 'www.clinic.ps', keyboard: TextInputType.url),
            const SizedBox(height: 12),
            _ltr(_license, 'رقم ترخيص المركز من وزارة الصحة (اختياري)', 'C-2024-118'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: _saving
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('حفظ'),
            ),
          ]),
        ),
      );
}
