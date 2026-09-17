import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_assistant/l10n/app_localizations.dart';

import '../../domain/entities/alarm/wake_alarm.dart';
import '../../domain/entities/alarm/wake_verification_config.dart';
import '../../domain/entities/alarm/wake_verification_state.dart';
import '../../core/theme/app_spacing.dart';
import '../providers/alarm_providers.dart';
import '../widgets/widgets.dart';

/// Full-screen alarm screen shown when alarm is ringing.
/// Displays alarm info, camera preview for face verification,
/// and action buttons for stop/snooze.
class WakeAlarmScreen extends ConsumerStatefulWidget {
  const WakeAlarmScreen({super.key, required this.alarm});

  final WakeAlarm alarm;

  @override
  ConsumerState<WakeAlarmScreen> createState() => _WakeAlarmScreenState();
}

class _WakeAlarmScreenState extends ConsumerState<WakeAlarmScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final alarm = widget.alarm;
    final vState = ref.watch(wakeVerificationStateProvider);

    final isRinging = vState == WakeVerificationState.ringing;
    final isChecking = vState == WakeVerificationState.checking ||
        vState == WakeVerificationState.faceDetected;
    final isAwaitingVoice =
        vState == WakeVerificationState.awaitingVoiceConfirmation;
    final isVerified = vState == WakeVerificationState.verified;

    return Scaffold(
      backgroundColor: isRinging
          ? cs.errorContainer.withOpacity(0.15)
          : isVerified
              ? cs.primaryContainer.withOpacity(0.15)
              : cs.surface,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            children: [
              // ─── Top: Time & Label ───
              SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    Text(
                      alarm.time.formatted,
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isRinging ? cs.error : cs.onSurface,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (alarm.label.isNotEmpty)
                      Text(
                        alarm.label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 24),
                    _buildStateIndicator(context, l10n, cs, vState),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // ─── Camera preview area ───
              if (isChecking || isAwaitingVoice)
                _buildCameraArea(context, cs, vState),

              // ─── Pulse ring when ringing ───
              if (isRinging) _buildPulseRing(cs),

              const Spacer(flex: 2),

              // ─── Action buttons ───
              SlideTransition(
                position: _slideAnimation,
                child: _buildActionButtons(
                  context,
                  l10n,
                  cs,
                  alarm,
                  isRinging,
                  isChecking,
                  isAwaitingVoice,
                  isVerified,
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateIndicator(
    BuildContext context,
    S l10n,
    ColorScheme cs,
    WakeVerificationState vState,
  ) {
    final icon = switch (vState) {
      WakeVerificationState.ringing => Icons.alarm,
      WakeVerificationState.checking => Icons.face,
      WakeVerificationState.faceDetected => Icons.face,
      WakeVerificationState.awaitingVoiceConfirmation => Icons.mic,
      WakeVerificationState.verified => Icons.check_circle,
      WakeVerificationState.snoozed => Icons.snooze,
      WakeVerificationState.timeout => Icons.timer_off,
      WakeVerificationState.error => Icons.error,
      _ => Icons.alarm,
    };

    final label = switch (vState) {
      WakeVerificationState.ringing => l10n.alarmRinging,
      WakeVerificationState.checking => l10n.alarmCheckingFace,
      WakeVerificationState.faceDetected => l10n.alarmFaceDetected,
      WakeVerificationState.awaitingVoiceConfirmation =>
        l10n.alarmAwaitingVoice,
      WakeVerificationState.verified => l10n.alarmVerified,
      WakeVerificationState.snoozed => l10n.alarmSnoozed,
      WakeVerificationState.timeout => l10n.alarmTimeout,
      WakeVerificationState.error => l10n.alarmError,
      _ => l10n.alarmScheduled,
    };

    final color = switch (vState) {
      WakeVerificationState.ringing => cs.error,
      WakeVerificationState.checking => cs.tertiary,
      WakeVerificationState.faceDetected => cs.tertiary,
      WakeVerificationState.awaitingVoiceConfirmation => cs.primary,
      WakeVerificationState.verified => cs.primary,
      _ => cs.onSurfaceVariant,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraArea(
    BuildContext context,
    ColorScheme cs,
    WakeVerificationState vState,
  ) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.outlineVariant,
          width: 1.5,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Live camera preview from WakeCameraService
          const CameraPreviewWidget(),
          if (vState == WakeVerificationState.faceDetected)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline, size: 12, color: Colors.white70),
                  SizedBox(width: 4),
                  Text(
                    S.of(context).alarmPrivacyMode,
                    style: TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseRing(ColorScheme cs) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: cs.error.withOpacity(0.15),
          border: Border.all(
            color: cs.error.withOpacity(0.4),
            width: 3,
          ),
        ),
        child: Icon(
          Icons.alarm,
          size: 56,
          color: cs.error,
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    S l10n,
    ColorScheme cs,
    WakeAlarm alarm,
    bool isRinging,
    bool isChecking,
    bool isAwaitingVoice,
    bool isVerified,
  ) {
    final notifier = ref.read(wakeVerificationStateProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Snooze button
        if (isRinging || isAwaitingVoice)
          AuraCard(
            onTap: () => notifier.snooze(alarm),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.snooze, color: cs.onSurfaceVariant, size: 24),
                SizedBox(width: 10),
                Text(
                  l10n.alarmSnooze,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),

        // Stop / Dismiss button
        if (isRinging || isChecking || isAwaitingVoice)
          _buildStopButton(context, l10n, cs, alarm, notifier),

        // Done button (when verified)
        if (isVerified) _buildDoneButton(context, l10n, cs, alarm, notifier),
      ],
    );
  }

  Widget _buildStopButton(
    BuildContext context,
    S l10n,
    ColorScheme cs,
    WakeAlarm alarm,
    WakeVerificationNotifier notifier,
  ) {
    if (!alarm.requiresVerification) {
      return AuraCard(
        onTap: () {
          notifier.stopAlarm(alarm);
          Navigator.of(context).pop();
        },
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        color: cs.errorContainer,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.stop_circle, color: cs.error, size: 24),
            SizedBox(width: 10),
            Text(
              l10n.alarmStop,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: cs.error,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      );
    }

    return AuraCard(
      onTap: () {
        if (alarm.verificationConfig.mode == WakeVerificationMode.none) {
          notifier.stopAlarm(alarm);
          Navigator.of(context).pop();
        }
      },
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      color: cs.primaryContainer,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wb_sunny_outlined, color: cs.primary, size: 24),
          SizedBox(width: 10),
          Text(
            l10n.alarmImAwake,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoneButton(
    BuildContext context,
    S l10n,
    ColorScheme cs,
    WakeAlarm alarm,
    WakeVerificationNotifier notifier,
  ) {
    return ElevatedButton(
      onPressed: () {
        notifier.stopAlarm(alarm);
        Navigator.of(context).pop();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: 24),
          SizedBox(width: 10),
          Text(
            l10n.alarmDone,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
