import 'package:flutter/material.dart';
import 'package:app_fe/models/order.dart';
import '../../services/order_service.dart';
import 'order_detail_screen.dart';
import 'widgets/order_card.dart';
import 'widgets/tabs.dart';
import "package:shared_preferences/shared_preferences.dart";


class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Order> _orders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
  setState(() {
    _loading = true;
    _error = null;
  });

  try {
    // Get token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      setState(() {
        _error = "Token not found (user not logged in)";
      });
      return;
    }

    final orders = await OrderService.fetchOrders(token);

    setState(() {
      _orders = orders;
    });
  } catch (e) {
    setState(() {
      _error = e.toString();
    });
  } finally {
    setState(() {
      _loading = false;
    });
  }
}


  List<Order> _filterByStatus(String status) {
    return _orders.where((o) => o.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F7),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Orders',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          OrdersTabBar(controller: _tabController),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : RefreshIndicator(
                        onRefresh: _loadOrders,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildList(_filterByStatus('PENDING')),
                            _buildList(_filterByStatus('DELIVERED')),
                            _buildList(_filterByStatus('CANCELLED')),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Order> list) {
    if (list.isEmpty) {
      return const Center(child: Text('No orders'));
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final order = list[i];
        return OrderCard(
          order: order,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailScreen(order: order),
              ),
            );
          },
        );
      },
    );
  }
}
