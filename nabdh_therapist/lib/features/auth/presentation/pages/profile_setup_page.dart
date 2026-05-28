import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isSubmitting = false;

  // Step 1 — Basic info
  final _nameController  = TextEditingController();
  final _titleController = TextEditingController();
  final _cityController  = TextEditingController();
  String _gender         = 'male';
  File?  _avatarFile;

  // Step 2 — Professional
  final _bioController        = TextEditingController();
  final _experienceController = TextEditingController();
  String _degree              = 'بكالوريوس';
  List<int>    _selectedSpecIds    = [];
  List<Map<String, dynamic>> _specializations = [];

  // Step 3 — Languages
  final List<Map<String, String>> _languages = [];
  final _langController = TextEditingController();
  String _langProficiency = 'fluent';

  static const _degrees = ['بكالوريوس', 'ماجستير', 'دكتوراه', 'دبلوم', 'زمالة'];
  static const _proficiencyLabels = {
    'basic': 'أساسية',
    'conversational': 'محادثة',
    'fluent': 'طليقة',
    'native': 'لغة أم',
  };
  static const _cities = [
    'رام الله', 'نابلس', 'الخليل', 'بيت لحم', 'جنين',
    'طولكرم', 'قلقيلية', 'أريحا', 'سلفيت', 'طوباس',
    'القدس', 'غزة', 'خانيونس', 'رفح', 'غيره',
  ];

  @override
  void initState() {
    super.initState();
    _loadSpecializations();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _titleController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    _langController.dispose();
    super.dispose();
  }

  Future<void> _loadSpecializations() async {
    try {
      final res = await ApiClient.instance.get('/specializations');
      final raw = res.data is List ? res.data : (res.data['data'] ?? []);
      setState(() {
        _specializations = List<Map<String, dynamic>>.from(raw);
      });
    } catch (e) {
      debugPrint('specializations error: $e');
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 800);
    if (img != null) setState(() => _avatarFile = File(img.path));
  }

  void _nextStep() {
    if (!_validateStep(_currentStep)) return;
    if (_currentStep < 2) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep--);
    }
  }

  bool _validateStep(int step) {
    String? error;
    switch (step) {
      case 0:
        if (_nameController.text.trim().length < 3) error = 'أدخل الاسم الكامل (3 أحرف على الأقل)';
        if (_cityController.text.trim().isEmpty)    error = 'اختر المدينة';
        break;
      case 1:
        if (_selectedSpecIds.isEmpty)                  error = 'اختر تخصصاً واحداً على الأقل';
        if (_experienceController.text.trim().isEmpty) error = 'أدخل سنوات الخبرة';
        break;
      case 2:
        if (_languages.isEmpty) error = 'أضف لغة واحدة على الأقل';
        break;
    }
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: AppColors.error,
      ));
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      // Upload avatar first if selected
      String? avatarPath;
      if (_avatarFile != null) {
        final form = await ApiClient.multipartPost('/therapist/profile/avatar', _avatarFile!.path, 'avatar');
        avatarPath = form.data['avatar_path'];
      }

      // Complete profile
      await ApiClient.instance.post('/therapist/profile/complete', data: {
        'full_name':          _nameController.text.trim(),
        'title':              _titleController.text.trim(),
        'bio':                _bioController.text.trim(),
        'gender':             _gender,
        'years_experience':   int.tryParse(_experienceController.text.trim()) ?? 0,
        'city':               _cityController.text.trim(),
        'degree':             _degree,
        'specialization_ids': _selectedSpecIds,
        if (avatarPath != null) 'avatar_path': avatarPath,
      });

      // Add languages
      for (final lang in _languages) {
        await ApiClient.instance.post('/therapist/profile/language', data: lang);
      }

      if (!mounted) return;
      context.go('/auth/pending');
    } catch (e) {
      if (mounted) {
        String msg = 'حدث خطأ، حاول مجدداً';
        if (e is DioException) {
          final data = e.response?.data;
          if (data is Map) {
            if (data['message'] != null) msg = data['message'];
            if (data['errors'] != null) {
              final errors = data['errors'] as Map;
              msg = errors.values.first is List
                  ? errors.values.first[0]
                  : errors.values.first.toString();
            }
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStepper(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                ],
              ),
            ),
            _buildNavButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: AppColors.surface,
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Text('نبض', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('إكمال الملف الشخصي', style: Theme.of(context).textTheme.titleMedium),
                Text('الخطوة ${_currentStep + 1} من 3', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    const labels = ['المعلومات', 'التخصص', 'اللغات'];
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
      child: Row(
        children: List.generate(3, (i) {
          final done    = i < _currentStep;
          final current = i == _currentStep;
          return Expanded(
            child: Row(
              children: [
                if (i > 0) Expanded(child: Container(height: 2, color: done ? AppColors.primary : AppColors.border)),
                Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done || current ? AppColors.primary : AppColors.border,
                      ),
                      child: Center(
                        child: done
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : Text('${i + 1}', style: TextStyle(color: current ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(labels[i], style: TextStyle(fontSize: 11, color: current ? AppColors.primary : AppColors.textSecondary, fontWeight: current ? FontWeight.w600 : FontWeight.normal)),
                  ],
                ),
                if (i < 2) Expanded(child: Container(height: 2, color: done ? AppColors.primary : AppColors.border)),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Step 1: Basic Info ──────────────────────────────────────────
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Avatar
          Center(
            child: GestureDetector(
              onTap: _pickAvatar,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: AppColors.border,
                    backgroundImage: _avatarFile != null ? FileImage(_avatarFile!) : null,
                    child: _avatarFile == null
                        ? const Icon(Icons.person, size: 48, color: AppColors.textSecondary)
                        : null,
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(child: TextButton(onPressed: _pickAvatar, child: const Text('إضافة صورة شخصية'))),

          const SizedBox(height: 20),
          _label('الاسم الكامل *'),
          TextField(controller: _nameController, decoration: const InputDecoration(hintText: 'مثال: أحمد محمد علي')),

          const SizedBox(height: 16),
          _label('اللقب المهني'),
          TextField(controller: _titleController, decoration: const InputDecoration(hintText: 'مثال: أخصائي علاج طبيعي')),

          const SizedBox(height: 16),
          _label('الجنس *'),
          _genderSelector(),

          const SizedBox(height: 16),
          _label('المدينة *'),
          _cityDropdown(),

          const SizedBox(height: 16),
          _label('نبذة شخصية'),
          TextField(
            controller: _bioController,
            maxLines: 3,
            maxLength: 500,
            decoration: const InputDecoration(hintText: 'اكتب نبذة مختصرة عن نفسك وخبرتك...'),
          ),
        ],
      ),
    );
  }

  // ── Step 2: Specialization & Experience ────────────────────────
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          _label('التخصصات * (يمكن اختيار أكثر من واحد)'),
          const SizedBox(height: 8),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _specializationsGrid(),

          const SizedBox(height: 20),
          _label('الدرجة العلمية *'),
          _degreeDropdown(),

          const SizedBox(height: 16),
          _label('سنوات الخبرة *'),
          TextField(
            controller: _experienceController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(hintText: '0', suffixText: 'سنة'),
          ),
        ],
      ),
    );
  }

  // ── Step 3: Languages ──────────────────────────────────────────
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _label('اللغات التي تتحدثها *'),
          const SizedBox(height: 4),
          Text('أضف اللغات التي يمكنك التواصل بها مع مرضاك', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),

          // Add language form
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('اللغة'),
                TextField(controller: _langController, decoration: const InputDecoration(hintText: 'مثال: العربية، الإنجليزية')),
                const SizedBox(height: 12),
                _label('مستوى الإتقان'),
                _proficiencyDropdown(),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _addLanguage,
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة اللغة'),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Languages list
          if (_languages.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: const Center(child: Text('لم تُضف أي لغة بعد', style: TextStyle(color: AppColors.textSecondary))),
            )
          else
            ..._languages.asMap().entries.map((e) => _languageChip(e.key, e.value)),
        ],
      ),
    );
  }

  Widget _languageChip(int index, Map<String, String> lang) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.language, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text('${lang['language']} — ${_proficiencyLabels[lang['proficiency']]}',
              style: const TextStyle(fontWeight: FontWeight.w500))),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
            onPressed: () => setState(() => _languages.removeAt(index)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // ── Nav buttons ────────────────────────────────────────────────
  Widget _buildNavButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.surface,
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  side: const BorderSide(color: AppColors.border),
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('رجوع'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _nextStep,
              child: _isSubmitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(_currentStep < 2 ? 'التالي' : 'إرسال الطلب'),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
  );

  Widget _genderSelector() {
    return Row(
      children: [
        Expanded(child: _genderOption('male', 'ذكر', Icons.male)),
        const SizedBox(width: 12),
        Expanded(child: _genderOption('female', 'أنثى', Icons.female)),
      ],
    );
  }

  Widget _genderOption(String value, String label, IconData icon) {
    final selected = _gender == value;
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? Colors.white : AppColors.textSecondary, size: 20),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _cityDropdown() {
    return DropdownButtonFormField<String>(
      value: _cityController.text.isEmpty ? null : _cityController.text,
      hint: const Text('اختر المدينة'),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        filled: true, fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: (v) { if (v != null) _cityController.text = v; },
    );
  }

  Widget _degreeDropdown() {
    return DropdownButtonFormField<String>(
      value: _degree,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        filled: true, fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: _degrees.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
      onChanged: (v) { if (v != null) setState(() => _degree = v); },
    );
  }

  Widget _specializationsGrid() {
    if (_specializations.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: const Center(child: Text('جاري التحميل...', style: TextStyle(color: AppColors.textSecondary))),
      );
    }
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: _specializations.map((spec) {
        final id       = spec['id'] as int;
        final selected = _selectedSpecIds.contains(id);
        return FilterChip(
          label: Text(spec['name_ar'] ?? ''),
          selected: selected,
          onSelected: (v) => setState(() => v ? _selectedSpecIds.add(id) : _selectedSpecIds.remove(id)),
          selectedColor: AppColors.primary.withOpacity(0.15),
          checkmarkColor: AppColors.primary,
          labelStyle: TextStyle(
            color: selected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
          side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
          backgroundColor: AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        );
      }).toList(),
    );
  }

  Widget _proficiencyDropdown() {
    return DropdownButtonFormField<String>(
      value: _langProficiency,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        filled: true, fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: _proficiencyLabels.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
      onChanged: (v) { if (v != null) setState(() => _langProficiency = v); },
    );
  }

  void _addLanguage() {
    final lang = _langController.text.trim();
    if (lang.isEmpty) return;
    if (_languages.any((l) => l['language'] == lang)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('هذه اللغة مضافة مسبقاً')));
      return;
    }
    setState(() {
      _languages.add({'language': lang, 'proficiency': _langProficiency});
      _langController.clear();
    });
  }
}
