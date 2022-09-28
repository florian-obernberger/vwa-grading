import 'package:flutter/material.dart';

class M3Toast extends StatelessWidget {
  const M3Toast({required this.content, super.key});

  final String content;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: colorScheme.surface,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Text(
          content,
          style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurface),
        ),
      ),
    );
    ;
  }
}
