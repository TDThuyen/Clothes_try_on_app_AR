import '../apis/order.dart' as api;
import '../models/orders/order_data.dart';

class OrderService {
  final api.OrderService _api = api.OrderService();

  /// Lấy danh sách đơn hàng theo status
  Future<List<Order>> getOrders({String? status}) async {
    return await _api.getOrders(status: status);
  }

  /// Lấy chi tiết một đơn hàng
  Future<Order> getOrderDetail(int orderId) async {
    return await _api.getOrderDetail(orderId);
  }

  /// Tạo đơn hàng mới
  Future<Order> createOrder({
    required String firstName,
    required String lastName,
    required String address,
    required int usedPoints,
    required List<Map<String, dynamic>> items,
  }) async {
    final body = {
      "firstName": firstName,
      "lastName": lastName,
      "address": address,
      "usedPoints": usedPoints,
      "items": items,
    };

    return await _api.createOrder(body);
  }
}
