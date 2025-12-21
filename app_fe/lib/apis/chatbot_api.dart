import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

// 🔑 FACE SESSION
import '../core/session/face_session_store.dart';

/// Response từ API chatbot
class ChatbotResponse {
  final String answer;
  final List<ProductSuggestion> products;

  ChatbotResponse({
    required this.answer,
    required this.products,
  });

  factory ChatbotResponse.fromJson(Map<String, dynamic> json) {
    final productsJson = json['products'] as List<dynamic>? ?? [];
    return ChatbotResponse(
      answer: json['answer'] as String? ?? '',
      products: productsJson
          .map((e) => ProductSuggestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Sản phẩm gợi ý từ chatbot
class ProductSuggestion {
  final int id;
  final String name;
  final double price;
  final String? imageUrl;
  final String? color;
  final String? gender;
  final String? availableSizes;

  ProductSuggestion({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    this.color,
    this.gender,
    this.availableSizes,
  });

  factory ProductSuggestion.fromJson(Map<String, dynamic> json) {
    return ProductSuggestion(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      imageUrl: json['imageUrl'] as String? ??
          json['image_url'] as String?,
      color: json['color'] as String?,
      gender: json['gender'] as String?,
      availableSizes: json['availableSizes'] as String? ??
          json['available_sizes'] as String?,
    );
  }
}

class ChatbotApi {
  static final String _baseUrl = AppConfig.baseUrl;

  static Future<ChatbotResponse> sendMessage(
    String message, {
    int? productId,
    String? token,
    String? sessionId, // 👈 optional override
  }) async {
    final uri = Uri.parse('$_baseUrl/api/chatbot');

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    // 🔑 LẤY SESSION ID
    final faceSessionId =
        sessionId ?? FaceSessionStore.get();

    final body = <String, dynamic>{
      'message': message,
    };

    if (productId != null) {
      body['productId'] = productId;
    }

    if (faceSessionId != null && faceSessionId.isNotEmpty) {
      body['sessionId'] = faceSessionId;
    }

    final resp = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    if (resp.statusCode != 200) {
      throw Exception(
        'Chatbot error: HTTP ${resp.statusCode} - ${resp.body}',
      );
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return ChatbotResponse.fromJson(data);
  }
}
