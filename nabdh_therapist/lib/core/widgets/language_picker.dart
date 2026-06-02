import 'package:flutter/material.dart';
import '../services/locale_service.dart';
import '../theme/app_theme.dart';

/// Language picker widget — can be placed in settings or profile page.
class LanguagePicker extends StatelessWidget {
  const LanguagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleService.instance,
      builder: (_, __) {
        final current = LocaleService.instance.locale.languageCode;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: LocaleService.supportedLocales.map((locale) {
            final code  = locale.languageCode;
            final name  = LocaleService.localeNames[code] ?? code;
            final flag  = LocaleService.localeFlags[code] ?? '🌐';
            final isSelected = code == current;

            return InkWell(
              onTap: () {
                LocaleService.instance.setLocale(locale);
                Navigator.of(context).pop();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Row(children: [
                  Text(flag, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(name,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 15,
                        color: isSelected
                            ? AppColors.primary : AppColors.textPrimary,
                      ))),
                  if (isSelected)
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.primary, size: 20),
                ]),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

/// Shows language picker as a modal bottom sheet.
void showLanguagePicker(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          width: 40, height: 4,
          decoration: BoxDecoration(
            color: AppColors.border, borderRadius: BorderRadius.circular(2)),
        ),
        const Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text('اختر اللغة / Choose Language / בחר שפה',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        ),
        const SizedBox(height: 16),
        const LanguagePicker(),
      ]),
    ),
  );
}
