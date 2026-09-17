import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/voice/voice_service.dart' show VoiceState;
import '../../core/providers/phase3_connection_points.dart';
import '../../core/theme/app_colors_adaptive.dart';
import 'glow_effect.dart';
import 'pulse_animation.dart';

/// AURA microphone button with visual voice states.
/// Wires to real VoiceService via voiceStateProvider.
class MicButton extends ConsumerWidget {
  const MicButton({
    super.key,
    this.size = 64,
    this.onTap,
  });

  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(voiceStateProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accent = AuraColors.accentOf(context);

    final (icon, color, glowEnabled, pulseEnabled) = switch (voiceState) {
      _ => (Icons.mic, Colors.grey, false, false),
      _ => (Icons.mic, Colors.grey, false, false),
      VoiceState.idle => (
          Icons.mic_none_rounded,
          cs.onSurfaceVariant,
          false,
          false,
        ),
      VoiceState.listening => (
          Icons.mic_rounded,
          accent,
          true,
          true,
        ),
      VoiceState.processing => (
          Icons.hourglass_top_rounded,
          accent.withOpacity(0.7),
          true,
          false,
        ),
      VoiceState.speaking => (
          Icons.volume_up_rounded,
          cs.secondary,
          true,
          false,
        ),
      VoiceState.error => (
          Icons.error_outline_rounded,
          cs.error,
          false,
          false,
        ),
    };

    Widget button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: size * 0.4, color: color),
    );

    if (pulseEnabled) {
      button = PulseAnimation(
        minScale: 0.94,
        maxScale: 1.06,
        duration: const Duration(milliseconds: 1000),
        child: button,
      );
    }

    button = GlowEffect(
      color: color,
      glowRadius: 30,
      enabled: glowEnabled,
      child: button,
    );

    // Expanding rings for listening state
    if (voiceState == VoiceState.listening) {
      button = Stack(
        alignment: Alignment.center,
        children: [
          ExpandingRing(
            color: accent.withOpacity(0.3),
            maxRadius: size * 0.9,
            duration: const Duration(milliseconds: 2000),
          ),
          ExpandingRing(
            color: accent.withOpacity(0.2),
            maxRadius: size * 1.2,
            duration: const Duration(milliseconds: 2500),
          ),
          button,
        ],
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: button,
    );
  }
}
