// lib/widgets/chatbot_overlay.dart

import 'package:flutter/material.dart';
import '../screens/chatbot_screen.dart';

class ChatbotOverlay extends StatelessWidget {
  final Widget child;

  /// Nếu từ màn chi tiết sản phẩm muốn truyền productId sang chatbot
  final int? productId;

  const ChatbotOverlay({
    Key? key,
    required this.child,
    this.productId,
  }) : super(key: key);

  void _openChatbot(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatbotScreen(
          productId: productId,
          // authToken: ... // nếu sau này cần
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        // Nút trôi góc dưới phải
        Positioned(
          right: 16,
          bottom: 24,
          child: GestureDetector(
            onTap: () => _openChatbot(context),
            child: Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'lib/assets/chatbot_button.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
