import 'package:flutter/material.dart';

class ElevatedCard extends Card {
  const ElevatedCard({
    super.key,
    super.color,
    super.shadowColor,
    super.surfaceTintColor,
    super.elevation,
    super.shape,
    super.borderOnForeground = true,
    super.margin,
    super.clipBehavior,
    super.child,
    super.semanticContainer = true,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      key: key,
      shape: shape ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: elevation ?? 1,
      color: color ?? colorScheme.surface,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      borderOnForeground: borderOnForeground,
      margin: margin,
      clipBehavior: clipBehavior,
      semanticContainer: semanticContainer,
      child: child,
    );
  }
}
