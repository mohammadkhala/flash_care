import 'package:doctor_flutter/utils/color_res.dart';
import 'package:flutter/material.dart';

class BlackGradientShadow extends StatelessWidget {
  final double? height;

  const BlackGradientShadow({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height ?? 300,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.transparent, ColorRes.black],
            begin: Alignment.topCenter,
            end: AlignmentDirectional.bottomCenter),
      ),
    );
  }
}
