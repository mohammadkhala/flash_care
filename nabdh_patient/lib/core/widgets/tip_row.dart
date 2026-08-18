import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Bullet row with an icon instead of emoji so Cairo font never breaks glyphs.
class TipRow extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String text;
  final TextStyle? textStyle;

  const TipRow({
    required this.icon,
    required this.text,
    this.iconColor,
    this.textStyle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: iconColor ?? AppColors.success),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: textStyle ??
                  const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                    fontFamily: 'Cairo',
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
