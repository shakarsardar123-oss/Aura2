import 'dart:async';

import '../../services/voice/voice_service.dart';
import '../../core/voice/speech_recognition_impl.dart';
import '../../core/voice/text_to_speech_impl.dart';

/// Real [VoiceService] implementation coordinating STT and TTS.
class VoiceServiceImpl implements VoiceService {
  VoiceServiceImpl({
    SpeechRecognitionServiceImpl? speechRecognition,
    TextToSpeechServiceImpl? textToSpeech,
  })  : _speechRecognition = speechRecognition ?? SpeechRecognitionServiceImpl(),
        _textToSpeech = textToSpeech ?? TextToSpeechServiceImpl();

  final SpeechRecognitionServiceImpl _speechRecognition;
  final TextToSpeechServiceImpl _textToSpeech;

  VoiceState _state = VoiceState.idle;
  final _stateController = StreamController<VoiceState>.broadcast();
  final _resultController = StreamController<String>.broadcast();
  void Function(String)? _onRecognized;

  @override
  VoiceState get state => _state;

  @override
  Stream<VoiceState> get stateStream => _stateController.stream;

  /// Stream of recognized text results.
  Stream<String>? get resultStream => _resultController.stream;

  void _setState(VoiceState newState) {
    if (_state != newState) {
      _state = newState;
      _stateController.add(_state);
    }
  }

  @override
  Future<void> startListening({
    required void Function(String text) onRecognized,
    String locale = 'ku',
  }) async {
    _onRecognized = onRecognized;
    _setState(VoiceState.listening);

    try {
      await _speechRecognition.startListening(
        onResult: (text) {
          _setState(VoiceState.processing);
          _resultController.add(text);
          _onRecognized?.call(text);
        },
        locale: locale,
      );
    } catch (e) {
      _setState(VoiceState.error);
    }
  }

  /// Alternative startListening with localeId param for wakeword compatibility.
  Future<void> startListeningWithLocaleId({
    required String localeId,
    required void Function(String text) onResult,
  }) async {
    return startListening(onRecognized: onResult, locale: localeId);
  }

  @override
  Future<void> stopListening() async {
    try {
      await _speechRecognition.stopListening();
    } finally {
      if (_state == VoiceState.listening) {
        _setState(VoiceState.idle);
      }
    }
  }

  @override
  Future<void> speak(String text, {String locale = 'ku'}) async {
    _setState(VoiceState.speaking);
    try {
      await _textToSpeech.speak(text, locale: locale);
    } catch (e) {
      _setState(VoiceState.error);
      return;
    }
    _setState(VoiceState.idle);
  }

  @override
  Future<void> stopSpeaking() async {
    try {
      await _textToSpeech.stop();
    } finally {
      if (_state == VoiceState.speaking) {
        _setState(VoiceState.idle);
      }
    }
  }

  /// Dispose resources.
  void dispose() {
    _stateController.close();
    _resultController.close();
  }
}
