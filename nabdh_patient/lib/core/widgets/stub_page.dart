import 'package:flutter/material.dart';

class StubPage extends StatelessWidget {
  final String title;
  const StubPage(this.title, {super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(child: Text('$title - قيد التطوير', style: const TextStyle(fontFamily: 'Cairo'))),
  );
}
