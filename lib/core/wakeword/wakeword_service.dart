import 'dart:async';

import '../voice/voice_service_impl.dart';

/// Service for wake word detection.
/// Listens for the wake word 'ئەورا' (AURA) in speech recognition
/// results and triggers a callback when detected.
///
/// P4 FIXES:
/// 1. Auto-restarts listening after STT timeout (speech_to_text stops
///    after ~10-15s of silence; this service detects that and restarts).
/// 2. Removed false-match strings ('hamaumin', 'ھامامین', 'حامامین')
///    that were leftover test strings causing false triggers.
/// 3. Added keyword spotter interface (abstract KwsService) for future
///    native KWS model integration (e.g., Porcupine, Snowboy).
/// 4. Documented that true always-on wake word requires a native KWS
///    model + foreground service (not currently implemented).
class WakeWordService {
  WakeWordService({
    required VoiceServiceImpl voiceService,
    String wakeWord = 'ئەورا',
  })  : _voiceService = voiceService,
        _wakeWord = wakeWord;

  final VoiceServiceImpl _voiceService;
  final String _wakeWord;

  bool _isListening = false;
  StreamSubscription<String>? _subscription;
  StreamSubscription<VoiceState>? _stateSubscription;
  void Function()? _onWakeWordDetected;
  Timer? _timeoutGuard;

  /// The wake word string (default: ئەورا).
  String get wakeWord => _wakeWord;

  /// Whether the service is actively listening for the wake word.
  bool get isListening => _isListening;

  /// Start listening for the wake word.
  /// When detected, [onWakeWordDetected] is called.
  Future<void> startListening({void Function()? onWakeWordDetected}) async {
    if (_isListening) return;

    _onWakeWordDetected = onWakeWordDetected;
    _isListening = true;

    await _startSttSession();

    // P4 FIX: Watch voice state to detect STT timeout (idle after listening)
    _stateSubscription = _voiceService.stateStream.listen((state) {
      if (!_isListening) return;
      // If STT auto-stopped (timed out on silence), voice goes idle
      if (state == VoiceState.idle || state == VoiceState.error) {
        _scheduleRestart();
      }
    });

    // P4 FIX: Periodic timeout guard in case state stream misses the stop
    _resetTimeoutGuard();
  }

  /// Stop listening for the wake word.
  Future<void> stopListening() async {
    if (!_isListening) return;

    _isListening = false;
    _timeoutGuard?.cancel();
    _timeoutGuard = null;
    await _stateSubscription?.cancel();
    _stateSubscription = null;
    await _subscription?.cancel();
    _subscription = null;
    _onWakeWordDetected = null;
    await _voiceService.stopListening();
  }

  Future<void> _startSttSession() async {
    try {
      await _voiceService.startListening(
        onRecognized: (text) {
          _checkForWakeWord(text);
        },
        locale: 'ckb_IQ',
      );

      // Subscribe to result stream as well
      _subscription = _voiceService.resultStream?.listen((text) {
        _checkForWakeWord(text);
      });
    } catch (e) {
      // STT init failed — schedule restart
      _scheduleRestart();
    }
  }

  /// P4 FIX: Schedule a restart of STT after a brief delay.
  /// This handles the speech_to_text timeout (~10-15s silence).
  void _scheduleRestart() {
    if (!_isListening) return;
    _timeoutGuard?.cancel();
    _timeoutGuard = Timer(const Duration(milliseconds: 800), () async {
      if (!_isListening) return;
      await _voiceService.stopListening();
      await Future.delayed(const Duration(milliseconds: 300));
      if (_isListening) {
        await _startSttSession();
        _resetTimeoutGuard();
      }
    });
  }

  /// P4 FIX: Reset the periodic timeout guard.
  /// If no state change is detected within 15 seconds, force a restart.
  void _resetTimeoutGuard() {
    _timeoutGuard?.cancel();
    _timeoutGuard = Timer(const Duration(seconds: 15), () {
      if (!_isListening) return;
      _scheduleRestart();
    });
  }

  void _checkForWakeWord(String text) {
    if (!_isListening) return;

    final normalized = text.toLowerCase().trim();
    final normalizedWakeWord = _wakeWord.toLowerCase().trim();

    // P4 FIX: Removed false-match strings ('hamaumin', 'ھامامین', 'حامامین')
    // that were leftover test strings causing false positive triggers.
    // Only match the actual AURA wake word.
    if (normalized.contains(normalizedWakeWord)) {
      _onWakeWordDetected?.call();
    }

    // Reset timeout guard on any speech activity (STT is still alive)
    _resetTimeoutGuard();
  }

  /// Dispose resources.
  void dispose() {
    stopListening();
  }
}

/// P4: Abstract interface for a native Keyword Spotting (KWS) service.
///
/// A real always-on wake word requires a native KWS model (e.g.,
/// Porcupine, Snowboy, or a custom TFLite model) running inside
/// a foreground service. This interface is provided so that a
/// future native implementation can be plugged in without changing
/// the WakeWordService architecture.
///
/// Current implementation uses STT-based detection which:
/// - Requires the app to be in the foreground
/// - Is battery-intensive (full speech recognition running continuously)
/// - May have false positives on similar-sounding words
/// - Stops after ~10-15s silence (auto-restart added as mitigation)
abstract class KwsService {
  /// Initialize the keyword spotting model.
  Future<bool> initialize();

  /// Start listening for the keyword.
  /// Calls [onKeywordDetected] when the wake word is spotted.
  Future<void> start({void Function()? onKeywordDetected});

  /// Stop listening for the keyword.
  Future<void> stop();

  /// Release model resources.
  void dispose();
}