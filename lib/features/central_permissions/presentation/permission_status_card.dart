// ───────────────────────────────────────────────────────────────────
// Step 16 – Central Permissions · Presentation · Status Card
// ───────────────────────────────────────────────────────────────────
// Single-permission card showing current status with a colored
// indicator, icon, name, and action button. Kurdish-first RTL.
// ───────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import 'package:aura_assistant/l10n/app_localizations.dart';
import 'package:aura_assistant/features/device_integration/domain/models/permission_status.dart';
import 'package:aura_assistant/features/central_permissions/domain/models/permission_explanation.dart';

/// A compact card that shows the status of a single [DevicePermission]
/// and lets the user request / open settings.
class PermissionStatusCard extends StatelessWidget {
  final DevicePermission permission;
  final PermissionStatus status;
  final VoidCallback? onRequest;
  final VoidCallback? onOpenSettings;

  const PermissionStatusCard({
    super.key,
    required this.permission,
    required this.status,
    this.onRequest,
    this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final theme = Theme.of(context);
    final explanation = PermissionExplanation.defaults[permission];
    final isCritical = explanation?.isCritical ?? false;

    final statusColor = switch (status) {
      PermissionStatus.granted => Colors.green,
      PermissionStatus.denied => Colors.orange,
      PermissionStatus.permanentlyDenied => Colors.red,
      PermissionStatus.unknown => Colors.grey,
    };

    final statusLabel = switch (status) {
      PermissionStatus.granted => S.of(context).translate('perm_granted'),
      PermissionStatus.denied => S.of(context).translate('perm_denied'),
      PermissionStatus.permanentlyDenied =>
          S.of(context).translate('perm_permanently_denied'),
      PermissionStatus.unknown =>
          S.of(context).translate('perm_unknown'),
    };

    final iconData = switch (permission) {
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCritical
            ? BorderSide(color: statusColor, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            // ── Status indicator dot ────────────────────────────────
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(
                right: isRtl ? 0 : 8,
                left: isRtl ? 8 : 0,
              ),
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),

            // ── Icon ────────────────────────────────────────────────
            Icon(iconData, size: 24, color: theme.colorScheme.primary),
            const SizedBox(width: 8),

            // ── Name + status ──────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment:
                    isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Row(
                    textDirection:
                        isRtl ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      Text(
                        S.of(context)
                            .translate('perm_${permission.name}_title'),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isCritical) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            S.of(context).translate('perm_critical'),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    statusLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),

            // ── Action ──────────────────────────────────────────────
            if (status == PermissionStatus.granted)
              Icon(Icons.check_circle, color: Colors.green, size: 24)
            else if (status == PermissionStatus.permanentlyDenied)
              TextButton(
                onPressed: onOpenSettings,
                child: Text(S.of(context).translate('perm_open_settings')),
              )
            else
              FilledButton.tonal(
                onPressed: onRequest,
                child: Text(S.of(context).translate('perm_request')),
              ),
          ],
        ),
      ),
    );
  }
}
