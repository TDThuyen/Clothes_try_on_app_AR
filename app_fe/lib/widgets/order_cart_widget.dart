import 'package:flutter/material.dart';
import '../models/orders/order_data.dart';
import '../screens/order_detail_screen.dart';

class OrderCardWidget extends StatelessWidget {
  final Order order;

  const OrderCardWidget({super.key, required this.order});

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String _statusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return "Pending";
      case OrderStatus.delivered:
        return "Delivered";
      case OrderStatus.cancelled:
        return "Cancelled";
    }
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          /// --------------------------
          /// ROW: Order # + Status
          /// --------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order #${order.id}",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(order.status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  _statusText(order.status),
                  style: TextStyle(
                    fontSize: 12,
                    color: _statusColor(order.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// --------------------------
          /// DATE
          /// --------------------------
          Row(
            children: [
              const Icon(Icons.calendar_month, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                _formatDate(order.createdAt),
                style: const TextStyle(color: Colors.grey),
              )
            ],
          ),

          const SizedBox(height: 10),

          /// --------------------------
          /// TRACKING NUMBER
          /// --------------------------
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined,
                  size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                order.id.toString(),
                style: const TextStyle(color: Colors.grey),
              )
            ],
          ),

          const SizedBox(height: 10),

          /// --------------------------
          /// QUANTITY
          /// --------------------------
          Row(
            children: [
              const Icon(Icons.shopping_bag_outlined,
                  size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                "${order.items.length} items",
                style: const TextStyle(color: Colors.grey),
              )
            ],
          ),

          const SizedBox(height: 10),

          /// --------------------------
          /// TOTAL
          /// --------------------------
          Row(
            children: [
              const Icon(Icons.attach_money,
                  size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                "${order.total.toStringAsFixed(0)} đ",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              )
            ],
          ),

          const SizedBox(height: 16),

          /// --------------------------
          /// DETAILS BUTTON
          /// --------------------------
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderDetailScreen(orderId: order.id),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Details",
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
