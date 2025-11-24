import 'package:flutter/foundation.dart';

/// ------------------------------
/// ENUM STATUS
/// ------------------------------
enum OrderStatus {
  pending,
  delivered,
  cancelled,
}

OrderStatus parseOrderStatus(String value) {
  switch (value.toUpperCase()) {
    case "PENDING":
      return OrderStatus.pending;
    case "DELIVERED":
      return OrderStatus.delivered;
    case "CANCELLED":
      return OrderStatus.cancelled;
    default:
      return OrderStatus.pending;
  }
}

/// ------------------------------
/// ORDER ITEM
/// ------------------------------
class OrderItem {
  final int id;
  final int productId;
  final int quantity;
  final String size;
  final double price;
  final ProductInOrder? product; // optional include

  OrderItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.size,
    required this.price,
    this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      productId: json['productId'],
      quantity: json['quantity'],
      size: json['size'],
      price: (json['price'] as num).toDouble(),
      product: json['product'] != null
          ? ProductInOrder.fromJson(json['product'])
          : null,
    );
  }
}

/// ------------------------------
/// PRODUCT (trong orderItems include)
/// ------------------------------
class ProductInOrder {
  final int id;
  final String name;
  final String imageUrl;

  ProductInOrder({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory ProductInOrder.fromJson(Map<String, dynamic> json) {
    return ProductInOrder(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'] ?? "",
    );
  }
}

/// ------------------------------
/// PAYMENT (nếu backend trả về)
/// ------------------------------
class PaymentData {
  final int id;
  final double amount;
  final String method;
  final DateTime createdAt;

  PaymentData({
    required this.id,
    required this.amount,
    required this.method,
    required this.createdAt,
  });

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    return PaymentData(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      method: json['method'] ?? "",
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

/// ------------------------------
/// ORDER MAIN MODEL
/// ------------------------------
class Order {
  final int id;
  final int userId;
  final String firstName;
  final String lastName;
  final String address;
  final double total;
  final int usedPoints;
  final int earnedPoints;
  final OrderStatus status;
  final DateTime createdAt;

  final List<OrderItem> items;
  final List<PaymentData>? payments;

  Order({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.total,
    required this.usedPoints,
    required this.earnedPoints,
    required this.status,
    required this.createdAt,
    required this.items,
    this.payments,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['userId'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      address: json['address'],
      total: (json['total'] as num).toDouble(),
      usedPoints: json['usedPoints'],
      earnedPoints: json['earnedPoints'],
      status: parseOrderStatus(json['status']),
      createdAt: DateTime.parse(json['createdAt']),

      items: (json['orderItems'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e))
          .toList(),

      payments: json['payments'] != null
          ? (json['payments'] as List)
              .map((e) => PaymentData.fromJson(e))
              .toList()
          : null,
    );
  }
}
