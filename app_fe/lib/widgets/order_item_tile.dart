import 'package:flutter/material.dart';
import '../models/orders/order_data.dart';

class OrderItemTile extends StatelessWidget {
  final OrderItem item;

  const OrderItemTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          
          /// --------------------------
          /// IMAGE
          /// --------------------------
          Container(
            width: 60,
            height: 60,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade200,
            ),
            child: item.product != null
                ? Image.network(
                    item.product!.imageUrl,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image, size: 28),
          ),

          const SizedBox(width: 12),

          /// --------------------------
          /// PRODUCT INFO
          /// --------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product?.name ?? "Product",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

          /// --------------------------
          /// PRICE
          /// --------------------------
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
}
