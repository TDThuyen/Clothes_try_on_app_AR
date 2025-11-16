// lib/services/api_service.dart
import 'dart:convert';
import 'dart:html' as html;

/// Lỗi chung cho các request API
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() => 'ApiException($statusCode, $message)';
}

class ApiService {
  /// Đổi lại nếu backend của bạn chạy port khác
  static const String _baseUrl = 'http://localhost:3000';

  /// Hàm GET generic, trả về dynamic (Map/List tuỳ JSON)
  static Future<dynamic> get(
      String path, {
        Map<String, String>? queryParameters,
      }) async {
    final uri =
    Uri.parse('$_baseUrl$path').replace(queryParameters: queryParameters);

    try {
      final req = await html.HttpRequest.request(
        uri.toString(),
        method: 'GET',
      );

      final status = req.status ?? 0;
      final text = req.responseText ?? '';

      if (status >= 200 && status < 300) {
        if (text.isEmpty) return null;
        return jsonDecode(text);
      } else {
        throw ApiException(
          statusCode: status,
          message: text.isNotEmpty ? text : (req.statusText ?? 'Unknown error'),
        );
      }
    } catch (e) {
      // Bị lỗi network/CORS thì thường là ProgressEvent
      if (e is html.ProgressEvent) {
        final target = e.target;
        if (target is html.HttpRequest) {
          throw ApiException(
            statusCode: target.status ?? 0,
            message: target.statusText ?? 'Network/CORS error',
          );
        }
      }
      rethrow;
    }
  }

  /// Hàm chuyên cho API searchProduct
  /// GET /product/searchProduct
  static Future<Map<String, dynamic>> searchProducts({
    required String q,
    double? minPrice,
    double? maxPrice,
    String? categoryName,
    String? gender,
    int page = 1,
    int limit = 20,
    String sortBy = 'newest',
  }) async {
    final params = <String, String>{
      'q': q,
      'page': '$page',
      'limit': '$limit',
      'sortBy': sortBy,
      if (minPrice != null) 'minPrice': minPrice.round().toString(),
      if (maxPrice != null) 'maxPrice': maxPrice.round().toString(),
      if (categoryName != null && categoryName.isNotEmpty)
        'categoryName': categoryName,
      if (gender != null && gender.isNotEmpty) 'gender': gender,
    };

    final data = await get('/product/searchProduct',
        queryParameters: params);

    if (data is Map<String, dynamic>) {
      return data;
    } else {
      // phòng trường hợp backend trả Array luôn
      return {
        'items': data,
      };
    }
  }
}
