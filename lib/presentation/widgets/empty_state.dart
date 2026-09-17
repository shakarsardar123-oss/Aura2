import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import 'aura_button.dart';

/// AURA empty state widget — shown when content lists are empty.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.icon,
    this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData? icon;
  final String? title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 64,
              color: cs.outline.withOpacity(0.5),
            ),
          if (icon != null) SizedBox(height: 16),
          if (title != null)
            Text(
              title!,
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          if (subtitle != null) ...[
            SizedBox(height: 8),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: 24),
            AuraButton(
              label: actionLabel!,
              onPressed: onAction,
              variant: AuraButtonVariant.outlined,
            ),
          ],
        ],
      ),
    );
  }
}

/// AURA loading indicator — centered spinner with optional message.
class AuraLoading extends StatelessWidget {
  const AuraLoading({
    super.key,
    this.message,
    this.size = 32,
  });

  final String? message;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: cs.primary,
          ),
        ),
        if (message != null) ...[
          SizedBox(height: 16),
          Text(
            message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// AURA error state widget.
class AuraErrorState extends StatelessWidget {
  const AuraErrorState({
    super.key,
    this.message,
    this.onRetry,
    this.retryLabel,
  });

  final String? message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: cs.error,
          ),
          SizedBox(height: 12),
          Text(
            message ?? 'Something went wrong',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(height: 16),
            AuraButton(
              label: retryLabel ?? 'Retry',
              onPressed: onRetry,
              variant: AuraButtonVariant.outlined,
            ),
          ],
        ],
      ),
    );
  }
}
