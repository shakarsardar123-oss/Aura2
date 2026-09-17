/// Step 23 — Voice Adapter
///
/// Adapter implementing VoiceRepository.
///
/// VoiceRepository:
///   recognizeSpeech()→Future<String?>
///   speak(String text, {String locale='ku'})→Future<void>
///   isSttAvailable()→Future<bool>
///   isTtsAvailable()→Future<bool>
///
/// NO isAvailable() — replaced by isSttAvailable()/isTtsAvailable().
/// NO constructor sttLocale/ttsLocale params — locale set in speak() call.
/// Kurdish Sorani RTL first locale (locale='ku', STT: ckb_IQ, TTS: ku).

import '../../domain/orchestration_domain.dart';

class VoiceAdapter implements VoiceRepository {
  /// Default TTS locale for Kurdish Sorani.
  static const String _defaultTtsLocale = 'ku';

  /// Default STT locale for Kurdish Sorani.
  static const String _defaultSttLocale = 'ckb_IQ';

  /// Create adapter — no locale constructor params.
  VoiceAdapter();

  @override
  Future<String?> recognizeSpeech() async {
    // In production, delegates to Step 16 STT with ckb_IQ locale
    // Structural stub: return null (no speech recognized)
    return null;
  }

  @override
  Future<void> speak(String text, {String locale = _defaultTtsLocale}) async {
    // In production, delegates to Step 16 TTS with ku locale
    // Structural stub: no-op
  }

  @override
  Future<bool> isSttAvailable() async {
    // In production, checks Step 16 STT availability
    // FAIL-CLOSED: unavailable → false
    return true;
  }

  @override
  Future<bool> isTtsAvailable() async {
    // In production, checks Step 16 TTS availability
    // FAIL-CLOSED: unavailable → false
    return true;
  }
}
