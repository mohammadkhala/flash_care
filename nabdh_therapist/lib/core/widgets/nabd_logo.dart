import 'package:flutter/material.dart';

/// Official NABD CARE mark from [assets/images/logo.png].
class NabdLogo extends StatelessWidget {
  final double size;
  final bool onDark;

  const NabdLogo({super.key, this.size = 120, this.onDark = false});

  static const assetPath = 'assets/images/logo.png';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 2.15,
      height: size,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class NabdBrandText extends StatelessWidget {
  final double fontSize;
  final bool onDark;
  const NabdBrandText({super.key, this.fontSize = 20, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: fontSize * 1.8,
      child: Image.asset(
        NabdLogo.assetPath,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
