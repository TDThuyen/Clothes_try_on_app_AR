import 'package:flutter/material.dart';

class OrdersTabBar extends StatelessWidget {
  final TabController controller;

  const OrdersTabBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F7),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: Colors.black,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black87,
        tabs: const [
          Tab(text: 'Pending'),
          Tab(text: 'Delivered'),
          Tab(text: 'Cancelled'),
        ],
      ),
    );
  }
}
