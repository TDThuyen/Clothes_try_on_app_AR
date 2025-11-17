import 'package:flutter/material.dart';
import '../../models/order.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final dateText =
        order.date.length >= 10 ? order.date.substring(0, 10) : order.date;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tracking: ${order.trackingNumber}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Date: $dateText'),
            const SizedBox(height: 8),
            Text('Quantity: ${order.quantity}'),
            const SizedBox(height: 8),
            Text('Subtotal: ${order.subtotal.toStringAsFixed(0)} ₫'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
