import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import '../core/session/face_session_store.dart';

class UnityScreen extends StatefulWidget {
  const UnityScreen({super.key});

  @override
  State<UnityScreen> createState() => _UnityScreenState();
}

class _UnityScreenState extends State<UnityScreen> {
  late UnityWidgetController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét khuôn mặt'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: UnityWidget(
        onUnityCreated: (controller) {
          _controller = controller;
        },

        /// 🔑 Unity → Flutter
        onUnityMessage: (message) async {
          if (message is String && message.isNotEmpty) {
            debugPrint('🟢 Face session from Unity: $message');

            await FaceSessionStore.save(message);

            if (mounted) {
              Navigator.pop(context, message); // trả sessionId về
            }
          }
        },
      ),
    );
  }
}
