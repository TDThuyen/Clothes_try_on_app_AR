import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/orders/order_data.dart';
import '../services/storage_service.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class OrderService {
  final String baseUrl = "${AppConfig.baseUrl}/orders";
  final StorageService storageService = StorageService();

  Future<String?> _token() async {
    return await storageService.read('accessToken');
  }

  /// ----------------------------------
  /// GET /orders?status=PENDING
  /// Lấy danh sách order theo status
  /// ----------------------------------
  Future<List<Order>> getOrders({String? status}) async {
    final token = await _token();

    final uri = Uri.parse(baseUrl).replace(
      queryParameters: status != null ? {"status": status} : null,
    );

    try {
      final res = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      final json = jsonDecode(res.body);

      if (res.statusCode == 200) {
        final list = json["data"] as List;
        return list.map((e) => Order.fromJson(e)).toList();
      }

      throw ApiException(json["message"] ?? "Server error");
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// ----------------------------------
  /// GET /orders/:id
  /// Lấy chi tiết order
  /// ----------------------------------
  Future<Order> getOrderDetail(int orderId) async {
    final token = await _token();

    final url = "$baseUrl/$orderId";

    try {
      final res = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      final json = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return Order.fromJson(json["data"]);
      }

      throw ApiException(json["message"] ?? "Server error");
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// ----------------------------------
  /// POST /orders
  /// Tạo order mới
  /// body = {
  ///   firstName, lastName, address, usedPoints, items: [...]
  /// }
  /// ----------------------------------
  Future<Order> createOrder(Map<String, dynamic> body) async {
    final token = await _token();

    try {
      final res = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      final json = jsonDecode(res.body);

      if (res.statusCode == 201 || res.statusCode == 200) {
        return Order.fromJson(json["data"]);
      }

      throw ApiException(json["message"] ?? "Server error");
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
