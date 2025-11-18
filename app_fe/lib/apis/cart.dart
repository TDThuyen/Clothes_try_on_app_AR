import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/cart/cart_data.dart';
import '../services/storage_service.dart';

class CartService {
  final String baseUrl = AppConfig.baseUrl;
  final StorageService storageService = StorageService();

  Future<String?> _token() async {
    return await storageService.read('accessToken');
  }

  // Fetch cart
  Future<List<CartItem>> fetchCart() async {
    final token = await _token();

    final res = await http.get(
      Uri.parse(baseUrl),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode != 200) return [];

    final data = jsonDecode(res.body);
    final items = data["cartItems"] as List;

    return items.map((i) => CartItem.fromJson(i)).toList();
  }

  // Update quantity
  Future<void> updateQuantity(int id, int qty) async {
    final token = await _token();

    await http.patch(
      Uri.parse("$baseUrl/$id/quantity"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"quantity": qty}),
    );
  }

  // Toggle selection
  Future<void> toggleSelection(int id, bool selected) async {
    final token = await _token();

    await http.patch(
      Uri.parse("$baseUrl/$id/select"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"isSelected": selected}),
    );
  }

  // Delete item
  Future<void> deleteItem(int id) async {
    final token = await _token();

    await http.delete(
      Uri.parse("$baseUrl/$id"),
      headers: {"Authorization": "Bearer $token"},
    );
  }
}
