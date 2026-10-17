import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json_utils.dart';

final _money = NumberFormat('#,##0.##', 'en');

String money(dynamic v) => '${_money.format(jsonDouble(v))} ₪';

String apiDate(DateTime d) => DateFormat('yyyy-MM-dd', 'en').format(d);

String showDate(String? s) {
  final d = s == null ? null : DateTime.tryParse(s);
  return d == null ? '' : DateFormat('dd/MM/yyyy', 'en').format(d);
}

const statusLabels = {
  'paid':    'مدفوع',
  'partial': 'جزئي',
  'unpaid':  'غير مدفوع',
  'none':    'لا شيء',
};

Color statusColor(String? s) => switch (s) {
  'paid'    => AppColors.success,
  'partial' => AppColors.warning,
  'unpaid'  => AppColors.error,
  _         => AppColors.textSecondary,
};

const paymentMethods = {
  'cash':          'نقداً',
  'card':          'بطاقة',
  'bank_transfer': 'تحويل بنكي',
  'other':         'أخرى',
};

const expenseCategories = {
  'rent':      'إيجار',
  'equipment': 'معدات',
  'salaries':  'رواتب',
  'supplies':  'مستلزمات',
  'utilities': 'كهرباء وخدمات',
  'other':     'أخرى',
};

const expenseIcons = {
  'rent':      Icons.home_work_outlined,
  'equipment': Icons.medical_services_outlined,
  'salaries':  Icons.badge_outlined,
  'supplies':  Icons.inventory_2_outlined,
  'utilities': Icons.bolt_outlined,
  'other':     Icons.receipt_long_outlined,
};

/// Server message (validation or abort) or a generic Arabic fallback.
String apiError(Object e) {
  if (e is DioException) {
    final data = e.response?.data;
    if (data is Map) {
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
      if (data['message'] is String) return data['message'] as String;
    }
    return 'تعذّر الاتصال بالخادم';
  }
  return 'حدث خطأ غير متوقع';
}

class StatusChip extends StatelessWidget {
  final String? status;
  const StatusChip(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withAlpha(28),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(statusLabels[status] ?? '—',
          style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
