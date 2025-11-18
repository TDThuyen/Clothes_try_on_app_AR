import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/product/search_product_response.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ProductService {
  final String baseUrl = AppConfig.baseUrl;

  // Search products with filter
  // GET /product?q=xxx&minPrice=..&maxPrice=..&categoryName=..&gender=..&page=..&limit=..&sortBy=...
  Future<ProductSearchResponse> searchProducts({
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

    final uri = Uri.parse('$baseUrl/product').replace(queryParameters: params);

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProductSearchResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Server error';
        throw ApiException(message);
      }
    } catch (e) {
      throw ApiException('$e');
    }
  }
}
