import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';

class OrderService {
  // Đổi IP/port cho đúng BE (nếu chạy trên máy ảo thật thì dùng IP của máy)
  static const String baseUrl = 'http://localhost:8080/api';

  // accessToken sẽ được set sau khi login / verify-otp
  static String? accessToken;

  static Future<List<Order>> fetchOrders(String token) async {
    final uri = Uri.parse('$baseUrl/orders');

    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch orders (${res.statusCode})');
    }

    final List data = jsonDecode(res.body)['data'];
    return data.map((e) => Order.fromJson(e)).toList();
  }
}
