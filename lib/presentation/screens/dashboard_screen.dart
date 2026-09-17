import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_assistant/l10n/app_localizations.dart';

import '../../core/providers/phase3_connection_points.dart';
import '../../services/voice/voice_service.dart' show VoiceState;
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../core/voice/voice_service_provider.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import '../../core/permissions/permission_service.dart';
import '../../core/agent/agent_context.dart';
import '../../core/reaction/reaction.dart';
import '../providers/app_providers.dart';
import '../widgets/widgets.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = S.of(context);
    final layout = ResponsiveLayout.of(context);
    final agentName = ref.watch(agentNameProvider);
    final voiceState = ref.watch(voiceStateProvider);
    final conversations = ref.watch(conversationHistoryProvider);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // ── Existing content ──
            LayoutContainer(
              maxWidth: layout.maxContentWidth,
              padding: EdgeInsets.symmetric(
                horizontal: layout.horizontalPadding,
                vertical: 8,
              ),
              child: CustomScrollView(
                slivers: [
                  // ── AURA Identity Header ──
                  SliverToBoxAdapter(child: _buildHeader(context, ref, agentName)),

                  // ── Greeting Section ──
                  SliverToBoxAdapter(child: _buildGreeting(context, l10n, agentName)),

                  // ── Status & Voice Entry Point ──
                  SliverToBoxAdapter(child: _buildVoiceSection(context, ref, l10n, voiceState)),

                  // ── Quick Actions ──
                  SliverToBoxAdapter(child: _buildQuickActions(context, ref, l10n, layout)),

                  // ── Recent Conversations / Empty State ──
                  SliverToBoxAdapter(
                    child: conversations.isEmpty
                        ? EmptyState(
                            icon: Icons.chat_bubble_outline_rounded,
                            title: l10n.noConversations,
                            subtitle: l10n.noConversationsSub,
                          )
                        : _buildRecentConversations(context, conversations),
                  ),

                  // Bottom padding
                  SliverToBoxAdapter(child: SizedBox(height: 24)),
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

  Widget _buildHeader(BuildContext context, WidgetRef ref, String agentName) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                agentName,
                style: AppTextStyles.auraLogo(context),
              ),
              SizedBox(width: 6),
              StatusIndicator(
                status: AuraStatus.ready,
                label: S.of(context).statusReady,
                size: 6,
              ),
            ],
          ),
          AuraIconButton(
            icon: Icons.settings_outlined,
            tooltip: S.of(context).settingsTab,
            onPressed: () {
              ref.read(navigationIndexProvider.notifier).state = 3;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting(BuildContext context, S l10n, String agentName) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.greeting,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          SizedBox(height: 4),
          Text(
            l10n.greetingSub,
            style: AppTextStyles.accentSubtitle(context),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceSection(BuildContext context, WidgetRef ref, S l10n, VoiceState voiceState) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: AuraCard(
        showGlow: voiceState == VoiceState.listening,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          children: [
            VoiceStatusIndicator(),
            SizedBox(height: 16),
            MicButton(
              size: 64,
              onTap: () => _handleMicTap(ref),
            ),
            SizedBox(height: 12),
            VoiceVisualizer(barCount: 28, maxBarHeight: 36),
            SizedBox(height: 8),
            Text(
              l10n.tapToStart,
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurfaceVariant,
              ),
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
        ref.read(voiceTranscriptProvider.notifier).update((_) => text);
        ref.read(voiceStateProvider.notifier).setState(VoiceState.processing);
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

  Widget _buildQuickActions(BuildContext context, WidgetRef ref, S l10n, ResponsiveLayout layout) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n.quickActions,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GridView.count(
            crossAxisCount: layout.gridColumns,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.1,
            children: [
              QuickActionCard(
                icon: Icons.translate_rounded,
                label: '\u0643\u0648\u0631\u062F\u06CC',
                subtitle: '\u0632\u0645\u0627\u0646\u06CC \u0643\u0648\u0631\u062F\u06CC',
                iconColor: const Color(0xFF00897B),
                onTap: () {},
              ),
              QuickActionCard(
                icon: Icons.school_outlined,
                label: '\u0641\u06D5\u06CC\u0631\u0628\u0648\u0648\u0646',
                subtitle: '\u06CC\u0627\u0631\u0645\u06D5\u062A\u06CC \u0642\u0648\u062A\u0627\u0628\u06CC',
                iconColor: const Color(0xFF7C4DFF),
                onTap: () {},
              ),
              QuickActionCard(
                icon: Icons.tips_and_updates_outlined,
                label: '\u0631\u0627\u0648\u06CE\u0698',
                subtitle: '\u0626\u0627\u0645\u0648\u0698\u06AF\u0627\u0631\u06CC',
                iconColor: const Color(0xFFFF6D00),
                onTap: () {},
              ),
              QuickActionCard(
                icon: Icons.visibility_outlined,
                label: l10n.visionTab,
                subtitle: l10n.visionQuickAction,
                iconColor: const Color(0xFF00BFA5),
                onTap: () {
                  ref.read(navigationIndexProvider.notifier).state = 1;
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentConversations(BuildContext context, List<ConversationItem> conversations) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Text(
            S.of(context).recentConversations,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...conversations.take(3).map((item) => AuraCard(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.chat_bubble_outline_rounded, color: cs.primary, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Text(
                      item.subtitle,
                      style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
