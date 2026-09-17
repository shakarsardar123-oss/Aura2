import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// AURA-branded card with consistent styling across themes.
///
/// Wraps [Card] with AURA spacing, radius, and optional glow effect.
class AuraCard extends StatelessWidget {
  const AuraCard({
    super.key,
    this.child,
    this.padding,
    this.borderRadius,
    this.glowColor,
    this.showGlow = false,
    this.onTap,
    this.margin,
  this.color,
  this.elevation,
  this.borderSide,
  this.width,
    this.height,
  });

  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? glowColor;
  final bool showGlow;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final BorderSide? borderSide;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = borderRadius ?? AppRadius.md;
    final cardColor = color ?? theme.cardTheme.color ?? theme.colorScheme.surface;
    final side = borderSide ??
        (theme.cardTheme.shape is RoundedRectangleBorder
            ? (theme.cardTheme.shape as RoundedRectangleBorder).side
            : BorderSide.none);

    Widget card = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(r),
        border: Border.fromBorderSide(side),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: glowColor ?? theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(r),
          child: Padding(
            padding: padding ?? AppSpacing.cardPadding,
            child: child,
          ),
        ),
      ),
    );

    return card;
  }
}
