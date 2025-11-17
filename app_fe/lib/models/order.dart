class Order {
  final int id;
  final String trackingNumber;
  final int quantity;
  final double subtotal;
  final String date;   // ISO string
  final String status; // "PENDING" | "DELIVERED" | "CANCELLED"

  Order({
    required this.id,
    required this.trackingNumber,
    required this.quantity,
    required this.subtotal,
    required this.date,
    required this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      trackingNumber: json['trackingNumber'] as String,
      quantity: json['quantity'] as int,
      subtotal: (json['subtotal'] as num).toDouble(),
      date: json['date'] as String,
      status: json['status'] as String,
    );
  }
}
