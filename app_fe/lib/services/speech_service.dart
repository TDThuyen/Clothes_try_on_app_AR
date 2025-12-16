import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final SpeechToText _speech = SpeechToText();
  bool isListening = false;

  Function(String text)? onResult;

  Future<bool> init() async {
    return await _speech.initialize(
      onStatus: _statusListener,
    );
  }

  void _statusListener(String status) {
    if (status == "notListening" && isListening) {
      Future.delayed(const Duration(milliseconds: 300), () {
        startListening();
      });
    }
  }

  Future<void> startListening() async {
    if (!_speech.isAvailable) await init();

    isListening = true;

    await _speech.listen(
      localeId: "vi_VN",
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        partialResults: true,
        autoPunctuation: true,
      ),
      onResult: (result) {
        if (onResult != null) onResult!(result.recognizedWords);
      },
    );
  }

  void stopListening() {
    isListening = false;
    _speech.stop();
  }
}
