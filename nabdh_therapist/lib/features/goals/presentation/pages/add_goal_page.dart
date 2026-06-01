import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';

class AddGoalPage extends StatefulWidget {
  final int patientId;
  final String patientName;

  const AddGoalPage({
    required this.patientId,
    required this.patientName,
    super.key,
  });

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _targetDate;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      locale: const Locale('ar'),
      helpText: 'تاريخ انتهاء الهدف',
    );
    if (d != null) setState(() => _targetDate = d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_targetDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تحديد التاريخ المستهدف'),
            backgroundColor: AppColors.error));
      return;
    }

    setState(() => _saving = true);
    try {
      await ApiClient.instance.post('/therapist/goals', data: {
        'patient_id':  widget.patientId,
        'title':       _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        'target_date': '${_targetDate!.year}-${_targetDate!.month.toString().padLeft(2,'0')}-${_targetDate!.day.toString().padLeft(2,'0')}',
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذّر الإنشاء: $e'),
              backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('هدف جديد لـ ${widget.patientName}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Title
            TextFormField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: 'عنوان الهدف *',
                hintText: 'مثال: المشي 500 متر بدون ألم',
                prefixIcon: const Icon(Icons.track_changes_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                filled: true, fillColor: AppColors.surface,
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'الرجاء إدخال عنوان' : null,
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'تفاصيل الهدف (اختياري)',
                hintText: 'صف الهدف بالتفصيل وكيف سيتم تقييمه...',
                prefixIcon: const Icon(Icons.description_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                filled: true, fillColor: AppColors.surface,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            // Target date
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _targetDate == null
                      ? AppColors.border : AppColors.primary),
                ),
                child: Row(children: [
                  Icon(Icons.calendar_today_rounded,
                      color: _targetDate == null ? AppColors.textHint : AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _targetDate == null
                          ? 'التاريخ المستهدف *'
                          : '${_targetDate!.year}/${_targetDate!.month.toString().padLeft(2,'0')}/${_targetDate!.day.toString().padLeft(2,'0')}',
                      style: TextStyle(
                        color: _targetDate == null ? AppColors.textHint : AppColors.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textHint),
                ]),
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _saving
                  ? const SizedBox(width: 24, height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('إنشاء الهدف',
                      style: TextStyle(color: Colors.white, fontSize: 16,
                          fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
