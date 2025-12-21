import 'package:flutter/material.dart';
import '../apis/chatbot_api.dart';

// 🔑 SESSION + UNITY
import '../core/session/face_session_store.dart';
import '../core/bridge/unity_launcher.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.createdAt,
  });
}

class ChatbotScreen extends StatefulWidget {
  final int? productId;
  final String? authToken;

  const ChatbotScreen({
    Key? key,
    this.productId,
    this.authToken,
  }) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];
  List<ProductSuggestion> _lastSuggestions = [];

  bool _isSending = false;
  bool _checkingFace = true;

  @override
  void initState() {
    super.initState();
    _ensureFaceSession();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // =========================================================
  // CHECK FACE SESSION – AUTO OPEN UNITY IF NEEDED
  // =========================================================
  Future<void> _ensureFaceSession() async {
    await Future.delayed(Duration.zero);

    if (!FaceSessionStore.hasSession()) {
      debugPrint('🟡 No face session → open Unity');
      await UnityLauncher.openUnity();
    }

    if (mounted) {
      setState(() {
        _checkingFace = false;
      });
    }
  }

  // =========================================================
  // SEND MESSAGE
  // =========================================================
  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isSending) return;

    // 🔒 BLOCK CHAT IF NO FACE SESSION
    if (!FaceSessionStore.hasSession()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng quét khuôn mặt trước khi trò chuyện'),
        ),
      );

      await UnityLauncher.openUnity();
      return;
    }

    final userMsg = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _inputController.clear();
      _isSending = true;
    });

    _scrollToBottom();

    try {
      final res = await ChatbotApi.sendMessage(
        text,
        productId: widget.productId,
        token: widget.authToken,
        sessionId: FaceSessionStore.get(), // 🔑 IMPORTANT
      );

      final botMsg = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        text: res.answer,
        isUser: false,
        createdAt: DateTime.now(),
      );

      setState(() {
        _messages.add(botMsg);
        _lastSuggestions = res.products;
      });

      _scrollToBottom();
    } catch (e) {
      final errorMsg = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        text: 'Xin lỗi, có lỗi xảy ra: $e',
        isUser: false,
        createdAt: DateTime.now(),
      );

      setState(() {
        _messages.add(errorMsg);
      });

      _scrollToBottom();
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // =========================================================
  // UI
  // =========================================================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_checkingFace) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tư vấn AI'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ================= CHAT AREA =================
          Expanded(
            child: Container(
              color: isDark ? Colors.black : Colors.grey.shade100,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg.isUser;

                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      constraints: BoxConstraints(
                        maxWidth:
                            MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: isUser
                            ? theme.colorScheme.primary
                            : (isDark
                                ? Colors.grey.shade800
                                : Colors.white),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                          bottomLeft:
                              Radius.circular(isUser ? 12 : 0),
                          bottomRight:
                              Radius.circular(isUser ? 0 : 12),
                        ),
                      ),
                      child: Text(
                        msg.text,
                        style: TextStyle(
                          color: isUser
                              ? Colors.white
                              : (isDark
                                  ? Colors.white
                                  : Colors.black87),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ================= PRODUCT SUGGESTIONS =================
          if (_lastSuggestions.isNotEmpty)
            Container(
              height: 150,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Text(
                      'Sản phẩm gợi ý',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: _lastSuggestions.length,
                      itemBuilder: (context, index) {
                        final p = _lastSuggestions[index];
                        return _buildProductCard(p);
                      },
                    ),
                  ),
                ],
              ),
            ),

          // ================= INPUT BAR =================
          SafeArea(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText:
                            'Hỏi về phong cách, tuổi, ngân sách, sản phẩm...',
                        border: InputBorder.none,
                      ),
                      minLines: 1,
                      maxLines: 4,
                    ),
                  ),
                  const SizedBox(width: 4),
                  _isSending
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _sendMessage,
                          color: theme.colorScheme.primary,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // PRODUCT CARD
  // =========================================================
  Widget _buildProductCard(ProductSuggestion p) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: p.imageUrl != null && p.imageUrl!.isNotEmpty
                    ? Image.network(
                        p.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.image_not_supported),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.image, size: 32),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                child: Text(
                  p.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                child: Text(
                  '${p.price.toStringAsFixed(0)} đ',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}
