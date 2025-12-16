import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../services/storage_service.dart';
import '../models/cart/cart_model.dart'; 

class CartApi {
  final StorageService _storageService = StorageService();

  Future<Map<String, String>?> _getHeaders() async {
    final token = await _storageService.read('accessToken');
    if (token == null) return null;
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 1. Lấy danh sách giỏ hàng
  // URL: http://10.0.2.2:3000/cart
  Future<CartModel?> getCart() async {
    try {
      final headers = await _getHeaders();
      if (headers == null) return null;

      // SỬA: Bỏ chữ /api đi
      final url = Uri.parse('${AppConfig.baseUrl}/cart'); 
      
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CartModel.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Lỗi kết nối Get Cart: $e');
      return null;
    }
  }

  // 2. Thêm vào giỏ hàng
  // URL: http://10.0.2.2:3000/cart
  Future<bool> addToCart({
    required int productId,
    required int quantity,
    required String size,
    required double price,
  }) async {
    try {
      final headers = await _getHeaders();
      if (headers == null) return false;

      final url = Uri.parse('${AppConfig.baseUrl}/cart');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'productId': productId,
          'quantity': quantity,
          'size': size,
          'price': price,
        }),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Lỗi Add Cart: $e');
      return false;
    }
  }

  // 3. Cập nhật số lượng
  // URL: http://10.0.2.2:3000/cart/123/quantity
  Future<bool> updateQuantity(int itemId, int quantity) async {
    try {
      final headers = await _getHeaders();
      if (headers == null) return false;

      final url = Uri.parse('${AppConfig.baseUrl}/cart/$itemId/quantity');

      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode({'quantity': quantity}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Lỗi Update Quantity: $e');
      return false;
    }
  }

  // 4. Chọn/Bỏ chọn sản phẩm
  // URL: http://10.0.2.2:3000/cart/123/select
  Future<bool> toggleSelection(int itemId, bool isSelected) async {
    try {
      final headers = await _getHeaders();
      if (headers == null) return false;

      final url = Uri.parse('${AppConfig.baseUrl}/cart/$itemId/select');

      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode({'isSelected': isSelected}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Lỗi Toggle Selection: $e');
      return false;
    }
  }

  // 5. Xóa sản phẩm
  // URL: http://10.0.2.2:3000/cart/123
  Future<bool> removeItem(int itemId) async {
    try {
      final headers = await _getHeaders();
      if (headers == null) return false;

      final url = Uri.parse('${AppConfig.baseUrl}/cart/$itemId');

      final response = await http.delete(url, headers: headers);

      return response.statusCode == 200;
    } catch (e) {
      print('Lỗi Remove Item: $e');
      return false;
    }
  }
}