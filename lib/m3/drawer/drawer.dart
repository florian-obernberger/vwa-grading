import 'dart:typed_data';

import 'package:flutter/material.dart';

class StandardDrawer extends StatelessWidget {
  const StandardDrawer({
    required this.items,
    required this.selectedIndex,
    required this.modal,
    this.onSelectionChanged,
    this.leading,
    this.trailing,
    super.key,
  }) : assert(items.length >= 2);

  final bool modal;
  final int selectedIndex;
  final ValueChanged<int>? onSelectionChanged;
  final List<StandardDrawerItem> items;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = ElevationOverlay.applySurfaceTint(
      colorScheme.surface,
      colorScheme.surfaceTint,
      modal ? 1 : 0,
    );

    return Container(
      height: double.infinity,
      width: 360,
      decoration: BoxDecoration(
        color: color,
        borderRadius: modal
            ? const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            if (leading != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: leading!,
              ),
            Expanded(
              child: ListView.builder(
                physics: const ClampingScrollPhysics(),
                itemBuilder: ((context, index) {
                  final item = items[index];
                  return SizedBox(
                    width: 336,
                    child: item._build(
                      context,
                      () => onSelectionChanged?.call(index),
                      modal,
                      index == selectedIndex,
                    ),
                  );
                }),
                itemCount: items.length,
              ),
            ),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: trailing!,
              ),
          ],
        ),
      ),
    );
  }
}

class StandardDrawerItem {
  const StandardDrawerItem({
    required this.label,
    required this.icon,
    this.selectedIcon,
  });

  final String label;
  final Widget icon;
  final Widget? selectedIcon;

  Widget _build(
    BuildContext context,
    GestureTapCallback onTap,
    bool modal, [
    bool selected = false,
  ]) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final foregroundColor = selected
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurfaceVariant;

    final backgroundColor = ElevationOverlay.applySurfaceTint(
      colorScheme.surface,
      colorScheme.surfaceTint,
      modal ? 1 : 0,
    );

    return FilledButton.icon(
      onPressed: onTap,
      icon: IconTheme(
        data: IconThemeData(color: foregroundColor, size: 24),
        child: selected ? selectedIcon ?? icon : icon,
      ),
      label: SizedBox(
        height: 56,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: foregroundColor,
            ),
          ),
        ),
      ),
      style: FilledButton.styleFrom(elevation: 0).copyWith(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.hovered)) {
            return selected
                ? Color.alphaBlend(
                    colorScheme.surfaceTint.withOpacity(0.08),
                    colorScheme.secondaryContainer,
                  )
                : Color.alphaBlend(
                    colorScheme.surfaceTint.withOpacity(0.08),
                    backgroundColor,
                  );
          } else {
            return selected ? colorScheme.secondaryContainer : backgroundColor;
          }
        }),
        shape: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.focused)) {
            return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: BorderSide(color: colorScheme.outline, width: 2),
            );
          } else {
            return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            );
          }
        }),
      ),
    );
  }
}
