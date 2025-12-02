import 'package:flutter/material.dart';
import '../services/order_service.dart';
import '../models/orders/order_data.dart';
import '../widgets/order_cart_widget.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({super.key});

  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OrderService _orderService = OrderService();

  bool isLoading = true;
  List<Order> pending = [];
  List<Order> delivered = [];
  List<Order> cancelled = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load orders on tab change
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      _loadOrders();
    });

    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => isLoading = true);

    try {
      pending = await _orderService.getOrders(status: "PENDING");
      delivered = await _orderService.getOrders(status: "DELIVERED");
      cancelled = await _orderService.getOrders(status: "CANCELLED");
    } catch (e) {
      debugPrint("Error loading orders: $e");
    }

    setState(() => isLoading = false);
  }

  Widget _renderList(List<Order> orders) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orders.isEmpty) {
      return const Center(
        child: Text(
          "No orders found",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemBuilder: (_, i) => OrderCardWidget(order: orders[i]),
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemCount: orders.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        title: const Text(
          "My Orders",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
      ),

      body: Column(
        children: [
          const SizedBox(height: 6),

          /// -----------------------------
          /// TAB BAR
          /// -----------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorWeight: 3,
              indicatorColor: Colors.black,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: "Pending"),
                Tab(text: "Delivered"),
                Tab(text: "Cancelled"),
              ],
            ),
          ),

          const SizedBox(height: 6),

          /// -----------------------------
          /// TAB CONTENT
          /// -----------------------------
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _renderList(pending),
                _renderList(delivered),
                _renderList(cancelled),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
