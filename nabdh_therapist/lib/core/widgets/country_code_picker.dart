import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/app_theme.dart';

/// Searchable dialling-code picker shared by the login and registration screens.
///
/// The list grew from two entries to every country the app accepts, which is too
/// many to scan, so it is searchable by country name and by code.
Future<String?> showCountryCodePicker(
  BuildContext context, {
  String? selected,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => _CountryCodeSheet(selected: selected),
  );
}

class _CountryCodeSheet extends StatefulWidget {
  final String? selected;
  const _CountryCodeSheet({this.selected});

  @override
  State<_CountryCodeSheet> createState() => _CountryCodeSheetState();
}

class _CountryCodeSheetState extends State<_CountryCodeSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final items = q.isEmpty
        ? AppConstants.countries
        : AppConstants.countries
            .where((c) =>
                c.name.toLowerCase().contains(q) ||
                c.code.contains(q) ||
                c.code.replaceFirst('+', '').contains(q))
            .toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: AppColors.border, borderRadius: BorderRadius.circular(4)),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 14, bottom: 10),
            child: Text('اختر رمز الدولة',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              autofocus: false,
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'ابحث باسم الدولة أو الرمز...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text('لا توجد نتائج',
                        style: TextStyle(color: AppColors.textSecondary)))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final c = items[i];
                      final isSelected = c.code == widget.selected;
                      return ListTile(
                        leading: Text(c.flag, style: const TextStyle(fontSize: 22)),
                        title: Text(c.name,
                            style: const TextStyle(
                                fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
                        trailing: Text(c.code,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            )),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        onTap: () => Navigator.pop(context, c.code),
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}
