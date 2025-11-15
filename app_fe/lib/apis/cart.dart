import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/cart/cart_data.dart';

class CartApi {
  static const String apiBase = "http://localhost:3000/cart";
  static const storage = FlutterSecureStorage();

  static Future<String?> _token() async {
    return await storage.read(key: "accessToken");
  }

  // Fetch cart
  static Future<List<CartItem>> fetchCart() async {
    final token = await _token();

    final res = await http.get(
      Uri.parse(apiBase),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode != 200) return [];

    final data = jsonDecode(res.body);
    final items = data["cartItems"] as List;

    return items.map((i) => CartItem.fromJson(i)).toList();
  }

  // Update quantity
  static Future<void> updateQuantity(int id, int qty) async {
    final token = await _token();

    await http.patch(
      Uri.parse("$apiBase/$id/quantity"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"quantity": qty}),
    );
  }

  // Toggle selection
  static Future<void> toggleSelection(int id, bool selected) async {
    final token = await _token();

    await http.patch(
      Uri.parse("$apiBase/$id/select"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"isSelected": selected}),
    );
  }

  // Delete item
  static Future<void> deleteItem(int id) async {
    final token = await _token();

    await http.delete(
      Uri.parse("$apiBase/$id"),
      headers: {"Authorization": "Bearer $token"},
    );
  }
}
