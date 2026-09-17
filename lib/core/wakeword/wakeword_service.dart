import 'dart:async';

import '../voice/voice_service_impl.dart';

/// Service for wake word detection.
/// Listens for the wake word 'حەمەومین' (HAMAUMIN) in speech recognition
/// results and triggers a callback when detected.
class WakeWordService {
  WakeWordService({
    required VoiceServiceImpl voiceService,
    String wakeWord = 'حەمەومین',
  })  : _voiceService = voiceService,
        _wakeWord = wakeWord;

  final VoiceServiceImpl _voiceService;
  final String _wakeWord;

  bool _isListening = false;
  StreamSubscription<String>? _subscription;
  void Function()? _onWakeWordDetected;

  /// The wake word string (default: حەمەومین).
  String get wakeWord => _wakeWord;

  /// Whether the service is actively listening for the wake word.
  bool get isListening => _isListening;

  /// Start listening for the wake word.
  /// When detected, [onWakeWordDetected] is called.
  Future<void> startListening({void Function()? onWakeWordDetected}) async {
    if (_isListening) return;

    _onWakeWordDetected = onWakeWordDetected;
    _isListening = true;

    // Start voice recognition
    await _voiceService.startListening(
      onRecognized: (text) {
        _checkForWakeWord(text);
      },
      locale: 'ckb_IQ',
    );

    // Also subscribe to the result stream
    _subscription = _voiceService.resultStream?.listen((text) {
      _checkForWakeWord(text);
    });
  }

  /// Stop listening for the wake word.
  Future<void> stopListening() async {
    if (!_isListening) return;

    _isListening = false;
    await _subscription?.cancel();
    _subscription = null;
    _onWakeWordDetected = null;
  }

  void _checkForWakeWord(String text) {
    if (!_isListening) return;

    final normalized = text.toLowerCase().trim();
    final normalizedWakeWord = _wakeWord.toLowerCase().trim();

    // Check for exact or approximate match (allows slight variations)
    if (normalized.contains(normalizedWakeWord) ||
        normalized.contains('hamaumin') ||
        normalized.contains('ھامامین') ||
        normalized.contains('حامامین')) {
      _onWakeWordDetected?.call();
    }
  }

  /// Dispose resources.
  void dispose() {
    stopListening();
  }
}
