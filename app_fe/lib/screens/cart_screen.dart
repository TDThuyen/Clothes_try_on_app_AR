import 'package:flutter/material.dart';
import 'package:app_fe/screens/checkout_address_screen.dart';
// Import các file mới
import '../models/cart/cart_model.dart';
import '../apis/cart.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Không dùng MaterialApp nữa để tránh lỗi điều hướng
    return const Scaffold(
      body: ShoppingCartScreen(),
    );
  }
}

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({Key? key}) : super(key: key);

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  // Dùng List<CartItemModel> mới
  List<CartItemModel> cartItems = [];
  bool loading = true;
  final CartApi _cartApi = CartApi();

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    final cart = await _cartApi.getCart();
    if (mounted) {
      setState(() {
        cartItems = cart?.items ?? [];
        loading = false;
      });
    }
  }

  Future<void> updateQuantity(int index, int newQuantity) async {
    final item = cartItems[index];

    // Cập nhật giao diện trước (Optimistic Update)
    setState(() {
      cartItems[index] = CartItemModel(
        id: item.id,
        productId: item.productId,
        quantity: newQuantity,
        size: item.size,
        price: item.price,
        isSelected: item.isSelected,
        product: item.product,
      );
    });

    await _cartApi.updateQuantity(item.id, newQuantity);
  }

  Future<void> toggleSelection(int index) async {
    final item = cartItems[index];
    final newStatus = !item.isSelected;

    setState(() {
      cartItems[index] = CartItemModel(
        id: item.id,
        productId: item.productId,
        quantity: item.quantity,
        size: item.size,
        price: item.price,
        isSelected: newStatus,
        product: item.product,
      );
    });

    await _cartApi.toggleSelection(item.id, newStatus);
  }

  Future<void> removeItem(int index) async {
    final item = cartItems[index];
    
    // Xóa trên giao diện
    setState(() {
      cartItems.removeAt(index);
    });

    // Gọi API xóa
    await _cartApi.removeItem(item.id);
  }

  double get subtotal {
    return cartItems.fold(
      0,
      (sum, item) => item.isSelected ? sum + (item.price * item.quantity) : sum,
    );
  }

  double get shipping => 0.0;
  double get total => subtotal + shipping;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Your Cart',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),

      body: cartItems.isEmpty 
        ? const Center(child: Text("Cart is empty"))
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    return CartItemCard(
                      item: cartItems[index],
                      onIncrement: () => updateQuantity(index, cartItems[index].quantity + 1),
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
          _buildPriceRow('Shipping', shipping == 0 ? 'Freeship' : '\$${shipping.toStringAsFixed(0)}'),
          const SizedBox(height: 12),
          _buildPriceRow('Subtotal', '\$${total.toStringAsFixed(0)}', isTotal: true),
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
                        MaterialPageRoute(builder: (context) => const CheckoutFirst()),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C2C2C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text(
                'Proceed to checkout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
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

class CartItemCard extends StatelessWidget {
  final CartItemModel item;
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
    // Lấy thông tin từ object product lồng bên trong
    final productName = item.product?.name ?? "Sản phẩm #${item.productId}";
    final imageUrl = item.product?.imageUrl ?? "";

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
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: item.isSelected ? const Color(0xFF4A9B8E) : Colors.white,
                border: Border.all(
                  color: item.isSelected ? const Color(0xFF4A9B8E) : Colors.grey[400]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: item.isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
          ),
          SizedBox(
            width: 80, height: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.image_not_supported, color: Colors.grey)),
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
                        productName,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
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
                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Size: ${item.size ?? "F"}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${item.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          GestureDetector(onTap: onDecrement, child: const Icon(Icons.remove, size: 16)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('${item.quantity}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          ),
                          GestureDetector(onTap: onIncrement, child: const Icon(Icons.add, size: 16)),
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