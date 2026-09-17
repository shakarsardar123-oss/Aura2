import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/wakeword/wakeword_service.dart';
import '../../core/voice/voice_service_provider.dart';

/// Provider for the WakeWordService.
final wakeWordServiceProvider = Provider<WakeWordService>((ref) {
  final voiceService = ref.watch(voiceServiceImplProvider);
  return WakeWordService(voiceService: voiceService);
});

/// Provider that tracks whether wake word detection is active.
final wakeWordActiveProvider = StateNotifierProvider<WakeWordActiveNotifier, bool>((ref) {
  return WakeWordActiveNotifier(ref.watch(wakeWordServiceProvider));
});

class WakeWordActiveNotifier extends StateNotifier<bool> {
  WakeWordActiveNotifier(this._wakeWordService) : super(false);

  final WakeWordService _wakeWordService;

  /// Start wake word listening.
  Future<void> start() async {
    await _wakeWordService.startListening(onWakeWordDetected: _onWakeWord);
    state = true;
  }

  /// Stop wake word listening.
  Future<void> stop() async {
    await _wakeWordService.stopListening();
    state = false;
  }

  void _onWakeWord() {
    // When wake word is detected, the voice screen or dashboard
    // should activate full listening mode.
    // This is wired via the VoiceService flow.
  }

  @override
  void dispose() {
    _wakeWordService.dispose();
    super.dispose();
  }
}
