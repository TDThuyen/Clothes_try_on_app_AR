import 'package:flutter/material.dart';
import '../session/face_session_store.dart';
import '../../screens/unity_screen.dart';

class UnityLauncher {
  static Future<String?> openUnityAndWaitSession(
    BuildContext context,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const UnityScreen(),
      ),
    );

    if (result is String && result.isNotEmpty) {
      await FaceSessionStore.save(result);
      return result;
    }

    return null;
  }

  static Future<void> openUnity() async {}
}
