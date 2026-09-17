import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

import '../../services/voice/text_to_speech_service.dart';
import '../../core/errors/failures.dart';

/// Real [TextToSpeechService] implementation using flutter_tts package.
class TextToSpeechServiceImpl implements TextToSpeechService {
  TextToSpeechServiceImpl();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  bool _isSpeaking = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _tts.awaitSpeakCompletion(true);
    _initialized = true;
    _tts.startHandler = () { _isSpeaking = true; };
    _tts.completionHandler = () { _isSpeaking = false; };
  }

  @override
  Future<bool> isAvailable() async {
    await _ensureInitialized();
    final engines = await _tts.getEngines;
    return engines != null && (engines as List).isNotEmpty;
  }

  @override
  Future<void> speak(String text, {String locale = 'ku'}) async {
    await _ensureInitialized();
    await _tts.setLanguage(locale);
    await _tts.setSpeechRate(0.9);
    await _tts.setPitch(1.0);
    _isSpeaking = true;
    final result = await _tts.speak(text);
    if (result != 1) {
      throw VoiceFailure(
        message: 'TTS failed to speak',
        code: 'TTS_SPEAK_FAILED',
      );
    }
  }

  @override
  Future<void> stop() async {
    _isSpeaking = false;
    await _tts.stop();
  }

  @override
  bool get isSpeaking => _isSpeaking;
}
