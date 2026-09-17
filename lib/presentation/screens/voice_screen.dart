import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_assistant/l10n/app_localizations.dart';

import '../../core/providers/phase3_connection_points.dart';
import '../../services/voice/voice_service.dart' show VoiceState;
import '../../core/theme/app_colors_adaptive.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/voice/voice_service_provider.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import '../../core/permissions/permission_service.dart';
import '../../core/agent/agent_context.dart';
import '../../core/reaction/reaction.dart';
import '../providers/app_providers.dart';
import '../widgets/widgets.dart';

class VoiceScreen extends ConsumerWidget {
  const VoiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = S.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    ref.watch(voiceStateProvider);
    final transcript = ref.watch(voiceTranscriptProvider);
    final aiResponse = ref.watch(aiResponseProvider);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // ── Existing content ──
            Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.voice,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      VoiceStatusIndicator(),
                    ],
                  ),
                  Spacer(flex: 2),

                  // Main voice area
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Large mic button
                      MicButton(
                        size: 96,
                        onTap: () => _handleMicTap(ref),
                      ),
                      SizedBox(height: 24),

                      // Voice visualizer
                      VoiceVisualizer(
                        barCount: 40,
                        maxBarHeight: 56,
                        barWidth: 3.5,
                      ),
                    ],
                  ),

                  Spacer(flex: 2),

                  // Transcript area
                  if (transcript.isNotEmpty || aiResponse.isNotEmpty)
                    AuraCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (transcript.isNotEmpty) ...[
                            Text(
                              '\u062A\u0648\u0627\u0645\u0627\u0631\u06A9\u0631\u0627\u0648',
                              style: TextStyle(
                                fontSize: 11,
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              transcript,
                              style: TextStyle(fontSize: 14, color: cs.onSurface),
                            ),
                          ],
                          if (aiResponse.isNotEmpty) ...[
                            SizedBox(height: 12),
                            Text(
                              '\u0648\u06D5\u0644\u0627\u0645',
                              style: TextStyle(
                                fontSize: 11,
                                color: AuraColors.accentOf(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              aiResponse,
                              style: TextStyle(fontSize: 14, color: cs.onSurface),
                            ),
                          ],
                        ],
                      ),
                    ),

                  // Hint text
                  SizedBox(height: 8),
                  Text(
                    l10n.tapToStart,
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurfaceVariant,
                    ),
                  ),

                  // Phase 3 notice
                  SizedBox(height: 12),
                  Text(
                    l10n.phaseNotice,
                    style: TextStyle(
                      fontSize: 10,
                      color: cs.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 8),
                ],
              ),
            ),

            // ── Reaction Banner overlay at top of screen ──
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AuraReactionBanner(),
            ),
          ],
        ),
      ),
    );
  }

  /// Real mic tap handler: checks permission, starts listening,
  /// sends recognized text to AgentEngine, and speaks the response.
  Future<void> _handleMicTap(WidgetRef ref) async {
    final voiceState = ref.read(voiceStateProvider);

    // If currently speaking or processing, stop and reset.
    if (voiceState == VoiceState.speaking || voiceState == VoiceState.processing) {
      final voiceService = ref.read(voiceServiceImplProvider);
      if (voiceState == VoiceState.speaking) {
        await voiceService.stopSpeaking();
      } else {
        await voiceService.stopListening();
      }
      return;
    }

    // If listening, stop listening.
    if (voiceState == VoiceState.listening) {
      final voiceService = ref.read(voiceServiceImplProvider);
      await voiceService.stopListening();
      return;
    }

    // If error, reset to idle.
    if (voiceState == VoiceState.error) {
      ref.read(voiceStateProvider.notifier).setState(VoiceState.idle);
      return;
    }

    // Start voice recognition from idle.
    final permissionService = PermissionService();
    final micResult = await permissionService.requestPermission(
      ph.Permission.microphone,
    );

    if (!micResult.isSuccess || !micResult.getOrElse(() => false)) {
      ref.read(voiceStateProvider.notifier).setState(VoiceState.error);
      return;
    }

    final voiceService = ref.read(voiceServiceImplProvider);

    await voiceService.startListening(
      onRecognized: (text) {
        // Update transcript when speech is recognized.
        ref.read(voiceTranscriptProvider.notifier).update((_) => text);
        ref.read(voiceStateProvider.notifier).setState(VoiceState.processing);

        // Send to agent engine.
        _processWithAgent(ref, text);
      },
      locale: 'ckb_IQ',
    );
  }

  /// Send recognized text to AgentEngine and speak the response.
  /// Step 5: Uses ReactionSpeechCoordinator to hold speech if banner is active.
  Future<void> _processWithAgent(WidgetRef ref, String userInput) async {
    try {
      final agentEngine = ref.read(agentEngineProvider);
      final agentConfig = ref.read(agentConfigProvider);

      final context = AgentContext(
        agentConfig: agentConfig,
        conversationHistory: [],
        maxSteps: 10,
      );

      final result = await agentEngine.run(
        userInput: userInput,
        context: context,
      );

      if (result.isSuccess && result.response != null) {
        ref.read(aiResponseProvider.notifier).update((_) => result.response!);

        // Step 5: coordinate speech with reaction banner lifecycle.
        final voiceService = ref.read(voiceServiceImplProvider);
        final coordinator = ref.read(reactionSpeechCoordinatorProvider);
        await coordinator.speakOrHold(
          result.response!,
          (text) => voiceService.speak(text),
        );
      } else {
        ref.read(aiResponseProvider.notifier).update((_) =>
            result.errorMessage ?? '\u0628\u0628\u0648\u0631\u064E\u060C \u0647\u06D5\u0644\u06D5\u06CC\u06CE\u0643 \u0631\u0648\u0648\u062F\u0627.');
        ref.read(voiceStateProvider.notifier).setState(VoiceState.error);
      }
    } catch (e) {
      ref.read(aiResponseProvider.notifier).update((_) => '\u0628\u0628\u0648\u0631\u064E\u060C \u0646\u06D5\u0645\u062A\u0627\u0646\u0645 \u0648\u064E\u0644\u0627\u0645 \u0628\u062F\u0647\u0645\u0647\u0648\u064E.');
      ref.read(voiceStateProvider.notifier).setState(VoiceState.error);
    }
  }
}
