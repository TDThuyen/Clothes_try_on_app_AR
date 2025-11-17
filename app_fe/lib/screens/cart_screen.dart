import 'package:flutter/material.dart';
import 'package:app_fe/screens/home_screen.dart';
import 'package:app_fe/screens/checkout_address_screen.dart';
import '../models/cart/cart_data.dart';
import '../apis/cart.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping Cart',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const ShoppingCartScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ======================================================================
//  SCREEN
// ======================================================================

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({Key? key}) : super(key: key);

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  List<CartItem> cartItems = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    final items = await CartApi.fetchCart();
    setState(() {
      cartItems = items;
      loading = false;
    });
  }

  Future<void> updateQuantity(int index, int newQuantity) async {
    final item = cartItems[index];

    setState(() {
      item.quantity = newQuantity;
    });

    await Future.delayed(const Duration(milliseconds: 700));
    await CartApi.updateQuantity(item.id, newQuantity);
  }

  Future<void> toggleSelection(int index) async {
    final item = cartItems[index];

    setState(() {
      item.isSelected = !item.isSelected;
    });

    await Future.delayed(const Duration(milliseconds: 300));
    await CartApi.toggleSelection(item.id, item.isSelected);
  }

  Future<void> removeItem(int index) async {
    final item = cartItems[index];
    await CartApi.deleteItem(item.id);

    setState(() {
      cartItems.removeAt(index);
    });
  }

  // ======================================================================
  //  TOTALS
  // ======================================================================

  double get subtotal {
    return cartItems.fold(
      0,
      (sum, item) => item.isSelected ? sum + (item.price * item.quantity) : sum,
    );
  }

  double get shipping => 0.0;
  double get total => subtotal + shipping;

  // ======================================================================
  //  UI
  // ======================================================================

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
        title: const Text(
          'Your Cart',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                return CartItemCard(
                  item: cartItems[index],
                  onIncrement: () {
                    updateQuantity(index, cartItems[index].quantity + 1);
                  },
                  onDecrement: () {
                    if (cartItems[index].quantity > 1) {
                      updateQuantity(index, cartItems[index].quantity - 1);
                    }
                  },
                  onRemove: () => removeItem(index),
                  onToggleSelection: () => toggleSelection(index),
                );
              },
            ),
          ),

          _summaryFooter(context),
        ],
      ),
    );
  }

  Widget _summaryFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPriceRow('Product price', '\$${subtotal.toStringAsFixed(0)}'),
          const SizedBox(height: 12),
          _buildPriceRow(
            'Shipping',
            shipping == 0 ? 'Freeship' : '\$${shipping.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 12),
          _buildPriceRow(
            'Subtotal',
            '\$${total.toStringAsFixed(0)}',
            isTotal: true,
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: subtotal == 0
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CheckoutFirst(),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C2C2C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Proceed to checkout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

// ======================================================================
//  CART ITEM CARD WIDGET
// ======================================================================

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;
  final VoidCallback onToggleSelection;

  const CartItemCard({
    Key? key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onToggleSelection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggleSelection,
            child: Container(
              margin: const EdgeInsets.only(top: 8, right: 8),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: item.isSelected ? const Color(0xFF4A9B8E) : Colors.white,
                border: Border.all(
                  color: item.isSelected
                      ? const Color(0xFF4A9B8E)
                      : Colors.grey[400]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: item.isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),

          SizedBox(
            width: 80,
            height: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.imageUrl ?? "",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 100,
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 30,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A9B8E),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  'Size: ${item.size}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: onDecrement,
                            child: const Icon(Icons.remove, size: 16),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: onIncrement,
                            child: const Icon(Icons.add, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
