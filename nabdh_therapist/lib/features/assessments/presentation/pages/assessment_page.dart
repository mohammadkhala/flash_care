import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';

enum AssessmentType { phq9, gad7, nrs, rom }

class AssessmentPage extends StatefulWidget {
  final int patientId;
  final AssessmentType type;
  const AssessmentPage({required this.patientId, required this.type, super.key});

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  final List<int> _answers = [];
  int _currentIndex = 0;
  bool _saving = false;
  bool _done = false;

  static const _phq9Questions = [
    'قلة الاهتمام أو المتعة في فعل الأشياء',
    'الشعور بالاكتئاب أو اليأس أو فقدان الأمل',
    'صعوبة في النوم أو النوم كثيراً',
    'الشعور بالتعب أو قلة الطاقة',
    'قلة الشهية أو الإفراط في تناول الطعام',
    'الشعور بالذنب أو أنك شخص فاشل',
    'صعوبة في التركيز على الأشياء',
    'التحرك أو الكلام ببطء شديد، أو العكس',
    'أفكار عن إيذاء النفس أو أنك لا تريد أن تحيا',
  ];

  static const _gad7Questions = [
    'الشعور بالتوتر أو القلق أو الترقب',
    'عدم القدرة على التوقف عن القلق أو التحكم فيه',
    'القلق الزائد حول أشياء مختلفة',
    'صعوبة في الاسترخاء',
    'الشعور بعدم الارتياح لدرجة يصعب معها الجلوس ساكناً',
    'التهيج أو سرعة الغضب',
    'الخوف من حدوث شيء سيئ',
  ];

  static const _romQuestions = [
    'قدرة المريض على ثني الكتف للأمام (Flexion)',
    'قدرة المريض على مد الكتف للخلف (Extension)',
    'قدرة المريض على ثني الركبة (Knee Flexion)',
    'قدرة المريض على مد الركبة (Knee Extension)',
    'قدرة المريض على ثني الرقبة للأمام (Neck Flexion)',
    'قدرة المريض على تدوير الرقبة (Cervical Rotation)',
    'قدرة المريض على ثني الظهر (Trunk Flexion)',
    'القدرة العامة على الحركة مقارنة بالمريض الطبيعي',
  ];

  static const _options        = ['أبداً', 'عدة أيام', 'أكثر من نصف الأيام', 'تقريباً كل يوم'];
  static const _romOptions     = ['طبيعي تماماً', 'محدود قليلاً', 'محدود بشكل معتدل', 'محدود بشكل شديد'];

  List<String> get _questions {
    switch (widget.type) {
      case AssessmentType.gad7: return _gad7Questions;
      case AssessmentType.rom:  return _romQuestions;
      default:                  return _phq9Questions;
    }
  }

  List<String> get _activeOptions =>
      widget.type == AssessmentType.rom ? _romOptions : _options;

  String get _typeName {
    switch (widget.type) {
      case AssessmentType.gad7: return 'GAD-7 (قلق)';
      case AssessmentType.nrs:  return 'NRS (مقياس الألم)';
      case AssessmentType.rom:  return 'ROM (نطاق الحركة)';
      default:                  return 'PHQ-9 (اكتئاب)';
    }
  }

  int get _totalScore => _answers.fold(0, (a, b) => a + b);

  String get _severity {
    switch (widget.type) {
      case AssessmentType.phq9:
        if (_totalScore <= 4)  return 'لا يوجد اكتئاب';
        if (_totalScore <= 9)  return 'اكتئاب خفيف';
        if (_totalScore <= 14) return 'اكتئاب متوسط';
        if (_totalScore <= 19) return 'اكتئاب متوسط شديد';
        return 'اكتئاب شديد';
      case AssessmentType.gad7:
        if (_totalScore <= 4)  return 'قلق طبيعي';
        if (_totalScore <= 9)  return 'قلق خفيف';
        if (_totalScore <= 14) return 'قلق متوسط';
        return 'قلق شديد';
      case AssessmentType.nrs:
        if (_totalScore == 0)  return 'لا ألم';
        if (_totalScore <= 3)  return 'ألم خفيف';
        if (_totalScore <= 6)  return 'ألم متوسط';
        if (_totalScore <= 8)  return 'ألم شديد';
        return 'ألم شديد جداً';
      case AssessmentType.rom:
        final pct = _totalScore / (_questions.length * 3) * 100;
        if (pct <= 10) return 'طبيعي';
        if (pct <= 35) return 'تحديد خفيف للحركة';
        if (pct <= 65) return 'تحديد معتدل للحركة';
        return 'تحديد شديد للحركة';
    }
  }

  Color get _severityColor {
    if (_totalScore <= 4) return AppColors.success;
    if (_totalScore <= 9) return AppColors.warning;
    if (_totalScore <= 14) return Colors.orange;
    return AppColors.error;
  }

  void _answer(int score) {
    setState(() {
      if (_currentIndex < _answers.length) {
        _answers[_currentIndex] = score;
      } else {
        _answers.add(score);
      }
      if (_currentIndex < _questions.length - 1) {
        _currentIndex++;
      } else {
        _done = true;
      }
    });
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      await ApiClient.instance.post('/therapist/assessments', data: {
        'patient_id': widget.patientId,
        'type':       widget.type.name,
        'answers':    _answers,
        'score':      _totalScore,
        'severity':   _severity,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ التقييم ✓')));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.error));
    } finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      title: Text(_typeName),
      leading: BackButton(onPressed: () => context.pop()),
    ),
    body: widget.type == AssessmentType.nrs
        ? _nrsView()
        : (_done ? _resultView() : _questionView()),
  );

  // ── NRS: single 0-10 pain slider ────────────────────────────────────────
  double _nrsValue = 5;
  Widget _nrsView() => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      const SizedBox(height: 40),
      const Text('قيّم شدة الألم من 0 إلى 10',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      const Text('0 = لا ألم  |  10 = ألم لا يُحتمل',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      const SizedBox(height: 40),
      StatefulBuilder(builder: (_, set) => Column(children: [
        Text('${_nrsValue.round()}',
            style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: AppColors.primary)),
        Slider(
          value: _nrsValue,
          min: 0, max: 10, divisions: 10,
          activeColor: AppColors.primary,
          onChanged: (v) => set(() => _nrsValue = v),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(11, (i) => Text('$i',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)))),
      ])),
      const Spacer(),
      SizedBox(width: double.infinity,
        child: ElevatedButton(
          onPressed: _saving ? null : () async {
            setState(() { _saving = true; });
            try {
              await ApiClient.instance.post('/therapist/assessments', data: {
                'patient_id': widget.patientId,
                'type':       'nrs',
                'answers':    [_nrsValue.round()],
                'score':      _nrsValue.round(),
                'severity':   _nrsValue.round() == 0 ? 'لا ألم'
                    : _nrsValue <= 3 ? 'ألم خفيف'
                    : _nrsValue <= 6 ? 'ألم متوسط'
                    : _nrsValue <= 8 ? 'ألم شديد' : 'ألم شديد جداً',
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حفظ التقييم ✓')));
                context.pop();
              }
            } catch (_) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('خطأ في الحفظ'), backgroundColor: AppColors.error));
            } finally { if (mounted) setState(() => _saving = false); }
          },
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          child: _saving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('حفظ التقييم', style: TextStyle(fontSize: 16)),
        ),
      ),
    ]),
  );

  Widget _questionView() {
    final progress = (_currentIndex + 1) / _questions.length;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Progress
        Row(children: [
          Text('${_currentIndex + 1}/${_questions.length}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const Spacer(),
          Text('${(progress * 100).round()}%',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
        const SizedBox(height: 32),

        // Question
        const Text('خلال الأسبوعين الماضيين، كم عانيت من:',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 12),
        Text(_questions[_currentIndex],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.5)),
        const SizedBox(height: 32),

        // Options
        ..._activeOptions.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _answer(e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: (_currentIndex < _answers.length && _answers[_currentIndex] == e.key)
                    ? AppColors.primary
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: (_currentIndex < _answers.length && _answers[_currentIndex] == e.key)
                      ? AppColors.primary
                      : AppColors.border,
                ),
              ),
              child: Row(children: [
                Text('${e.key}', style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 16,
                  color: (_currentIndex < _answers.length && _answers[_currentIndex] == e.key)
                      ? Colors.white : AppColors.primary,
                )),
                const SizedBox(width: 16),
                Expanded(child: Text(e.value, style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w500,
                  color: (_currentIndex < _answers.length && _answers[_currentIndex] == e.key)
                      ? Colors.white : AppColors.textPrimary,
                ))),
              ]),
            ),
          ),
        )),

        // Back button
        if (_currentIndex > 0) ...[
          const Spacer(),
          TextButton.icon(
            onPressed: () => setState(() { _currentIndex--; _done = false; }),
            icon: const Icon(Icons.arrow_back),
            label: const Text('السؤال السابق'),
          ),
        ],
      ]),
    );
  }

  Widget _resultView() => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      const SizedBox(height: 20),
      Container(
        width: 120, height: 120,
        decoration: BoxDecoration(
          color: _severityColor.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: _severityColor, width: 3),
        ),
        child: Center(child: Text('$_totalScore',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: _severityColor))),
      ),
      const SizedBox(height: 20),
      Text(_typeName, style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
      const SizedBox(height: 8),
      Text(_severity, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _severityColor)),
      const SizedBox(height: 32),

      // Score breakdown
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: _questions.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              Expanded(child: Text(e.value,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${e.key < _answers.length ? _answers[e.key] : 0}',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ]),
          )).toList(),
        ),
      ),
      const SizedBox(height: 32),

      SizedBox(width: double.infinity,
        child: ElevatedButton(
          onPressed: _saving ? null : _submit,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          child: _saving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('حفظ التقييم في ملف المريض', style: TextStyle(fontSize: 16)),
        ),
      ),
      const SizedBox(height: 12),
      TextButton(
        onPressed: () => setState(() { _answers.clear(); _currentIndex = 0; _done = false; }),
        child: const Text('إعادة التقييم'),
      ),
    ]),
  );
}
