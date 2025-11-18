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

  // THÊM HÀM MỚI NÀY
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
