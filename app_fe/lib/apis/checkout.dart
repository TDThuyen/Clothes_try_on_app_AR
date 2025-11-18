import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/checkout/checkout_data.dart';
import '../config/app_config.dart';
import '../services/storage_service.dart';

class CheckoutService {
  final String baseUrl = AppConfig.baseUrl;
  final StorageService storageService = StorageService();

  Future<String?> _token() async {
    return await storageService.read('accessToken');
  }

  /// PLACE ORDER
  Future<http.Response?> placeOrder(
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
