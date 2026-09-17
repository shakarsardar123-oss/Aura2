import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// AURA-branded button variants.
enum AuraButtonVariant {
  filled,
  outlined,
  text,
  glow,
}

/// AURA-branded button with consistent styling.
class AuraButton extends StatelessWidget {
  const AuraButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AuraButtonVariant.filled,
    this.icon,
    this.glowColor,
    this.fontSize,
    this.padding,
    this.borderRadius,
    this.isLoading = false,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AuraButtonVariant variant;
  final IconData? icon;
  final Color? glowColor;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final bool isLoading;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    if (isLoading) {
      return SizedBox(
        width: fullWidth ? double.infinity : null,
        child: _buildContainer(
          context,
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == AuraButtonVariant.outlined || variant == AuraButtonVariant.text
                  ? cs.primary
                  : cs.onPrimary,
            ),
          ),
        ),
      );
    }

    final labelWidget = Text(
      label,
      style: TextStyle(
        fontSize: fontSize ?? 14,
        fontWeight: FontWeight.w600,
      ),
    );

    Widget child;
    if (icon != null) {
      child = Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          SizedBox(width: 8),
          labelWidget,
        ],
      );
    } else {
      child = labelWidget;
    }

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: _buildContainer(context, child: child),
    );
  }

  Widget _buildContainer(BuildContext context, {required Widget child}) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final r = borderRadius ?? AppRadius.md;
    final effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 12);

    VoidCallback? effectiveOnPressed = isLoading ? null : onPressed;

    switch (variant) {
      case AuraButtonVariant.filled:
        return FilledButton(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
            padding: effectivePadding,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r)),
          ),
          child: child,
        );

      case AuraButtonVariant.outlined:
        return OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            padding: effectivePadding,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r)),
          ),
          child: child,
        );

      case AuraButtonVariant.text:
        return TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(
            padding: effectivePadding,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r)),
          ),
          child: child,
        );

      case AuraButtonVariant.glow:
        return Container(
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(r),
            boxShadow: [
              BoxShadow(
                color: glowColor ?? cs.primary.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(r),
            child: InkWell(
              onTap: effectiveOnPressed,
              borderRadius: BorderRadius.circular(r),
              child: Padding(
                padding: effectivePadding,
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        );
    }
  }
}

/// Compact icon button with AURA styling.
class AuraIconButton extends StatelessWidget {
  const AuraIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.size = 40,
    this.iconSize = 20,
    this.color,
    this.backgroundColor,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final double iconSize;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Widget button = SizedBox(
      width: size,
      height: size,
      child: Material(
        color: backgroundColor ?? cs.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(size / 2),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: Icon(
            icon,
            size: iconSize,
            color: color ?? cs.onSurface,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
