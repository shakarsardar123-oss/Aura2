import 'package:flutter/material.dart';

import '../../core/theme/app_colors_adaptive.dart';

/// AURA bottom navigation bar with Material 3 styling.
class AuraNavigationBar extends StatelessWidget {
  const AuraNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  required this.destinations,
  this.height = 64,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accent = AuraColors.accentOf(context);

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(
            color: cs.outlineVariant.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations,
        height: height,
        backgroundColor: Colors.transparent,
        indicatorColor: accent.withOpacity(0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}

/// Layout container that provides responsive structure.
class LayoutContainer extends StatelessWidget {
  const LayoutContainer({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
    this.centerContent = true,
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;
  final bool centerContent;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.scaffoldBackgroundColor;

    Widget content = child;

    if (centerContent && maxWidth != null) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth!),
          child: content,
        ),
      );
    }

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    return Container(color: bgColor, child: content);
  }
}
