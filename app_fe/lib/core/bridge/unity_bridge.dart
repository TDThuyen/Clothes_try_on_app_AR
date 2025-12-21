import 'package:flutter/services.dart';

class UnityBridge {
  static const MethodChannel _channel =
      MethodChannel('unity/face_session');

  static void init({
    required void Function(String sessionId) onSession,
  }) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onFaceSessionCreated') {
        final sessionId = call.arguments as String;
        onSession(sessionId);
      }
    });
  }
}
