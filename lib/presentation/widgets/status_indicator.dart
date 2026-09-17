import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_assistant/l10n/app_localizations.dart';

import '../../services/voice/voice_service.dart' show VoiceState;
import '../../core/providers/phase3_connection_points.dart';

/// AURA status indicator dot with label.
enum AuraStatus { online, offline, ready }

class StatusIndicator extends StatelessWidget {
  const StatusIndicator({
    super.key,
    required this.status,
    this.label,
    this.showDot = true,
  this.size = 8,
  this.style,
  });

  final AuraStatus status;
  final String? label;
  final bool showDot;
  final double size;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final dotColor = switch (status) {
      AuraStatus.online => const Color(0xFF00E676),
      AuraStatus.offline => cs.outline,
      AuraStatus.ready => cs.primary,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showDot)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              boxShadow: status == AuraStatus.online
                  ? [
                      BoxShadow(
                        color: dotColor.withOpacity(0.4),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
        if (label != null && showDot) SizedBox(width: 6),
        if (label != null)
          Text(
            label!,
            style: style ??
                TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
          ),
      ],
    );
  }
}

/// Status indicator from VoiceState (Phase 3 connection point).
class VoiceStatusIndicator extends ConsumerWidget {
  const VoiceStatusIndicator({super.key, this.style});

  final TextStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(voiceStateProvider);
    final l10n = S.of(context);

    final (status, label) = switch (voiceState) {
      VoiceState.idle => (AuraStatus.ready, l10n.voiceIdle),
      VoiceState.listening => (AuraStatus.online, l10n.voiceListening),
      VoiceState.processing => (AuraStatus.ready, l10n.voiceProcessing),
      VoiceState.speaking => (AuraStatus.online, l10n.voiceSpeaking),
      VoiceState.error => (AuraStatus.offline, l10n.voiceError),
    };

    return StatusIndicator(
      status: status,
      label: label,
      style: style,
    );
  }
}
