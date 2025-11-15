import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../models/checkout/checkout_data.dart';

class CheckoutApi {
  static const storage = FlutterSecureStorage();
  static const String baseUrl = "http://localhost:3000/checkout";

  static Future<String?> _token() async {
    return await storage.read(key: "accessToken");
  }

  /// PLACE ORDER
  static Future<http.Response?> placeOrder(
    CheckoutData checkoutData,
    String paymentMethod,
  ) async {
    final token = await _token();
    if (token == null) return null;

    final body = {
      ...checkoutData.toJson(),
      "shippingMethod": checkoutData.shippingMethod,
      "couponCode": checkoutData.coupon,
      "paymentMethod": paymentMethod,
    };

    try {
      final res = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      return res;
    } catch (e) {
      return null;
    }
  }
}
