import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product/search_product_response.dart';
import '../config/app_config.dart';

class ApiService {
  Future<List<Product>> getGlassesByGender(String gender) async {
    try {
      final categoryId = gender == 'MALE' ? 1 : 2;
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/products?category_id=$categoryId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Product>> getAllGlasses() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/products?category_id=1,2'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Product>> getAllProducts() async {
    try {
      // Endpoint này giả định backend có một route trả về tất cả sản phẩm
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/products'),
      );

      if (response.statusCode == 200) {
        // Backend của bạn trả về dữ liệu trong key 'data'
        final responseBody = json.decode(response.body);
        final List<dynamic> data = responseBody['data'];
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load all products');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ========== THÊM METHOD MỚI CHO AR SELECTION ==========
  /// Lấy sản phẩm theo categoryId - trả về List<Map<String, dynamic>>
  Future<List<Map<String, dynamic>>> getProductsByCategoryId(
    int categoryId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/products?categoryId=$categoryId'),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        // Xử lý cả 2 trường hợp: response là List hoặc Object có key 'data'
        if (responseBody is List) {
          return List<Map<String, dynamic>>.from(responseBody);
        } else if (responseBody is Map && responseBody.containsKey('data')) {
          final data = responseBody['data'];
          if (data is List) {
            return List<Map<String, dynamic>>.from(data);
          } else if (data is Map && data.containsKey('items')) {
            return List<Map<String, dynamic>>.from(data['items']);
          }
        }
        return [];
      } else {
        throw Exception('Failed to load products for category $categoryId');
      }
    } catch (e) {
      print('Error getProductsByCategoryId: $e');
      return [];
    }
  }

  Future<List<Product>> searchProducts({
    String? categoryName,
    String? gender,
    String? sortBy,
  }) async {
    try {
      // Xây dựng các tham số query một cách linh hoạt
      final Map<String, String> queryParameters = {
        if (categoryName != null) 'categoryName': categoryName,
        if (gender != null) 'gender': gender,
        if (sortBy != null) 'sortBy': sortBy,
      };

      // Tạo URI với các tham số đã xây dựng
      final uri = Uri.parse(
        '${AppConfig.baseUrl}/api/products/search',
      ).replace(queryParameters: queryParameters);
      print(uri);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        // Backend trả về một object lớn, trong đó có key 'data'
        final paginatedData = responseBody['data'];
        // Dữ liệu sản phẩm thực sự nằm trong key 'items' của object đó
        final List<dynamic> items = paginatedData['items'];
        return items.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search products: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
