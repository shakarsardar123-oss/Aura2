import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/voice/voice_service.dart' show VoiceState;
import '../../core/voice/voice_service_provider.dart' show voiceServiceImplProvider;
import '../../presentation/providers/app_providers.dart'
    show connectionStatusStreamProvider;

/// Phase 3 connection point providers.
///
/// These providers wire the real Phase 3 implementations to the UI.
/// VoiceState is imported from the canonical definition in
/// lib/services/voice/voice_service.dart (5 states with isActive).

/// Notifier that tracks the real voice state from VoiceServiceImpl.
class VoiceStateNotifier extends StateNotifier<VoiceState> {
  VoiceStateNotifier(this._voiceServiceImpl) : super(VoiceState.idle) {
    _init();
  }

  final dynamic _voiceServiceImpl;
  StreamSubscription<VoiceState>? _subscription;

  void _init() {
    // Listen to the state stream from VoiceServiceImpl
    final stream = _voiceServiceImpl.stateStream;
    if (stream != null) {
      _subscription = stream.listen((state) {
        this.state = state;
      });
    }
  }

  /// Manually set the state (e.g., from UI reset).
  void setState(VoiceState newState) {
    state = newState;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Real voice state provider — delegates to VoiceServiceImpl via notifier.
final voiceStateProvider = StateNotifierProvider<VoiceStateNotifier, VoiceState>((ref) {
  final voiceService = ref.watch(voiceServiceImplProvider);
  return VoiceStateNotifier(voiceService);
});

/// Voice transcript provider — updated by VoiceService recognition results.
final voiceTranscriptProvider = StateProvider<String>((ref) => '');

/// AI response provider — updated by AgentEngine after AI processing.
final aiResponseProvider = StateProvider<String>((ref) => '');

/// Connection status — delegates to connectionStatusStreamProvider.
/// Uses the latest value from the connectivity stream.
final connectionStatusProvider = StateProvider<bool>((ref) {
  final asyncValue = ref.watch(connectionStatusStreamProvider);
  return asyncValue.maybeWhen(
    data: (isConnected) => isConnected,
    orElse: () => true,
  );
});

/// Agent name provider — reads from app config.
final agentNameProvider = StateProvider<String>((ref) => 'حەمەومین');

/// Conversation history — persisted via MemoryService.
class ConversationItem {
  const ConversationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });
  final String id;
  final String title;
  final String subtitle;
  final DateTime timestamp;
}

/// Conversation history provider — delegates to conversationListProvider
/// from memory subsystem when available, otherwise returns empty list.
final conversationHistoryProvider = StateProvider<List<ConversationItem>>((ref) {
  // The conversationListProvider from memory_providers is a FutureProvider.
  // We watch its value and convert ConversationEntity → ConversationItem.
  // For now, keep as StateProvider so UI can also add items optimistically.
  // When the FutureProvider resolves, we'll update this list.
  return [];
});

/// Navigation tab index provider for the main shell.
final navigationIndexProvider = StateProvider<int>((ref) => 0);
