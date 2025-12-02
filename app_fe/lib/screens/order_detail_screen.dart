import 'package:flutter/material.dart';
import '../models/orders/order_data.dart';
import '../services/order_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();

  bool isLoading = true;
  Order? order;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final data = await _orderService.getOrderDetail(widget.orderId);
      setState(() {
        order = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading detail: $e");
      setState(() => isLoading = false);
    }
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _statusText(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return "Pending";
      case OrderStatus.delivered:
        return "Delivered";
      case OrderStatus.cancelled:
        return "Cancelled";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || order == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final o = order!;

    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        title: const Text("Order Details"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              /// --------------------------
              /// STATUS BADGE
              /// --------------------------
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(o.status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusText(o.status),
                    style: TextStyle(
                      color: _statusColor(o.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// --------------------------
              /// ORDER INFORMATION
              /// --------------------------
              const Text(
                "Order Information",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow("Order ID", "#${o.id}"),
                    _infoRow("Name", "${o.firstName} ${o.lastName}"),
                    _infoRow("Address", o.address),
                    _infoRow(
                      "Created At",
                      "${o.createdAt.day}/${o.createdAt.month}/${o.createdAt.year}",
                    ),
                    _infoRow("Items", "${o.items.length}"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// --------------------------
              /// ORDER ITEMS LIST
              /// --------------------------
              const Text(
                "Items",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 10),

              Column(
                children: o.items
                    .map((item) => _itemTile(item))
                    .toList(),
              ),

              const SizedBox(height: 20),

              /// --------------------------
              /// SUMMARY
              /// --------------------------
              const Text(
                "Summary",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Column(
                  children: [
                    _summaryRow("Subtotal", "${o.total.toStringAsFixed(0)} đ"),
                    _summaryRow("Shipping", "0 đ"),
                    const Divider(),
                    _summaryRow(
                      "Total",
                      "${o.total.toStringAsFixed(0)} đ",
                      isBold: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// --------------------------
              /// BUTTONS
              /// --------------------------
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.black),
                      ),
                      child: const Text(
                        "Rate",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.black,
                      ),
                      child: const Text("Reorder"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper: build info rows
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  /// Helper: item tile
  Widget _itemTile(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        children: [
          /// Image
          Container(
            width: 60,
            height: 60,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade200,
            ),
            child: item.product != null
                ? Image.network(item.product!.imageUrl, fit: BoxFit.cover)
                : const Icon(Icons.image, size: 28),
          ),

          const SizedBox(width: 12),

          /// Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product?.name ?? "Product",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Size: ${item.size}   Qty: ${item.quantity}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          /// Price
          Text(
            "${item.price.toStringAsFixed(0)} đ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper: summary row
  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              )),
          Text(value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              )),
        ],
      ),
    );
  }
}
