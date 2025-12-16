import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService instance = TtsService._internal();
  final FlutterTts _tts = FlutterTts();

  bool _initialized = false;
  bool isSpeaking = false;
  Function()? onComplete;

  TtsService._internal() {
    _init();
  }

  Future<void> _init() async {
    if (_initialized) return;

    await _tts.setLanguage("vi-VN");
    await _tts.setSpeechRate(1.0);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setCompletionHandler(() {
      isSpeaking = false;
      if (onComplete != null) onComplete!();
    });

    _initialized = true;
  }

  Future<void> speak(String text) async {
    if (!_initialized) await _init();

    isSpeaking = true;
    await _tts.speak(text);
  }

  Future<void> pause() => _tts.pause();
  Future<void> stop() => _tts.stop();
}
