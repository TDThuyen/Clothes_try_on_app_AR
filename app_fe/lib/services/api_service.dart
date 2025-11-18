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
}
