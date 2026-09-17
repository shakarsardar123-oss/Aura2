import 'package:speech_to_text/speech_to_text.dart';

/// Real speech-to-text implementation wrapping the speech_to_text package.
class SpeechRecognitionServiceImpl {
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;

  Future<bool> initialize() async {
    if (_initialized) return true;
    _initialized = await _speech.initialize();
    return _initialized;
  }

  Future<void> startListening({
    required void Function(String text) onResult,
    String locale = 'ku',
  }) async {
    if (!_initialized) {
      await initialize();
    }
    await _speech.listen(
      localeId: locale,
      onResult: (result) {
        onResult(result.recognizedWords);
      },
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }
}
