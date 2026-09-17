// ───────────────────────────────────────────────────────────────────
// Step 16 – Central Permissions · Presentation · Explanation Sheet
// ───────────────────────────────────────────────────────────────────
// Bottom sheet explaining WHY a permission is needed before the
// system dialog appears.  Kurdish-first RTL, critical badges.
// ───────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import 'package:aura_assistant/l10n/app_localizations.dart';
import 'package:aura_assistant/features/central_permissions/domain/models/permission_explanation.dart';

/// Modal bottom sheet that explains why a permission is needed.
///
/// Returns `true` if the user taps "Continue", `false` if dismissed.
Future<bool> showPermissionExplanationSheet({
  required BuildContext context,
  required PermissionExplanation explanation,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _ExplanationSheet(explanation: explanation),
  ).then((v) => v ?? false);
}

class _ExplanationSheet extends StatelessWidget {
  final PermissionExplanation explanation;

  const _ExplanationSheet({required this.explanation});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          // ── Handle bar ────────────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Title row ─────────────────────────────────────────────
          Row(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              _PermIcon(permission: explanation.permission),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  S.of(context).translate(explanation.titleKey),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (explanation.isCritical)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    S.of(context).translate('perm_critical'),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onError,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Body ──────────────────────────────────────────────────
          Text(
            S.of(context).translate(explanation.bodyKey),
            style: theme.textTheme.bodyMedium,
            textAlign: isRtl ? TextAlign.right : TextAlign.left,
          ),

          const SizedBox(height: 12),

          // ── Feature hint ─────────────────────────────────────────
          Text(
            '${S.of(context).translate('perm_used_by')} ${S.of(context).translate('feature_${explanation.featureName}')}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
            ),
            textAlign: isRtl ? TextAlign.right : TextAlign.left,
          ),

          const SizedBox(height: 24),

          // ── Actions ───────────────────────────────────────────────
          Row(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(S.of(context).translate('perm_not_now')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(S.of(context).translate('perm_continue')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small icon representing a permission category.
class _PermIcon extends StatelessWidget {
  final DevicePermission permission;

  const _PermIcon({required this.permission});

  @override
  Widget build(BuildContext context) {
    final IconData icon = switch (permission) {
      DevicePermission.accessibility => Icons.accessibility_new,
      DevicePermission.overlay => Icons.layers,
      DevicePermission.screenCapture => Icons.screenshot_monitor,
      DevicePermission.microphone => Icons.mic,
      DevicePermission.camera => Icons.camera_alt,
      DevicePermission.storage => Icons.sd_storage,
      DevicePermission.notification => Icons.notifications,
      DevicePermission.batteryOptimization => Icons.battery_charging_full,
      DevicePermission.assistant => Icons.assistant,
      DevicePermission.location => Icons.location_on,
    };

    return CircleAvatar(
      radius: 20,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Icon(icon, size: 20),
    );
  }
}
