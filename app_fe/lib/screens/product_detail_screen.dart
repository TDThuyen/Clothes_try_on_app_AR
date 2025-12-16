import 'package:flutter/material.dart';
import '../apis/product.dart';
import '../models/product/product_model.dart';
// THÊM: Import API Giỏ hàng
import '../apis/cart.dart'; 

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({Key? key, required this.productId}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<ProductModel?> _productFuture;
  final ProductService _productService = ProductService();
  
  // THÊM: Khởi tạo API Giỏ hàng
  final CartApi _cartApi = CartApi(); 

  // THÊM: Biến lưu size đang chọn
  String? _selectedSize;
  bool _isAddingToCart = false; // Biến loading khi bấm nút thêm

  @override
  void initState() {
    super.initState();
    _productFuture = _productService.getProductById(widget.productId);
  }

  // THÊM: Hàm xử lý thêm vào giỏ
  void _handleAddToCart(ProductModel product) async {
    // 1. Kiểm tra đã chọn size chưa
    if (_selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng chọn Size trước!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isAddingToCart = true;
    });

    // 2. Gọi API thêm vào giỏ
    final success = await _cartApi.addToCart(
      productId: product.id,
      quantity: 1, 
      size: _selectedSize!,
      price: product.price,
    );

    setState(() {
      _isAddingToCart = false;
    });

    // 3. Thông báo kết quả
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Đã thêm ${product.name} (Size $_selectedSize) vào giỏ!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Lỗi: Không thể thêm vào giỏ hàng"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<ProductModel?>(
        future: _productFuture,
        builder: (context, snapshot) {
          // 1. Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // 2. Lỗi
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text("Lỗi: ${snapshot.error ?? 'Không tìm thấy sản phẩm'}"),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _productFuture = _productService.getProductById(widget.productId);
                      });
                    },
                    child: const Text("Thử lại"),
                  )
                ],
              ),
            );
          }

          // 3. Data OK
          final product = snapshot.data!;
          // Tách chuỗi size thành List (Ví dụ: "S,M,L" -> ["S", "M", "L"])
          List<String> sizes = product.availableSizes.isNotEmpty 
              ? product.availableSizes.split(',').map((e) => e.trim()).toList()
              : [];

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // --- Header Ảnh ---
                  SliverAppBar(
                    expandedHeight: 400,
                    pinned: true,
                    backgroundColor: Colors.white,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, size: 50),
                        ),
                      ),
                    ),
                    leading: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white70,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),

                  // --- Nội dung ---
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tên & Giá
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                "\$${product.price}",
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Rating
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 20),
                              const SizedBox(width: 5),
                              Text("${product.ratingAvg}/5.0", style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(width: 10),
                              Container(height: 15, width: 1, color: Colors.grey),
                              const SizedBox(width: 10),
                              Text(product.gender, style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 25),

                          // --- PHẦN CHỌN SIZE (Đã sửa logic tương tác) ---
                          if (sizes.isNotEmpty) ...[
                            const Text("Select Size", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: sizes.map((size) {
                                final isSelected = _selectedSize == size;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedSize = isSelected ? null : size;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.black : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected ? Colors.black : Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      size,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 25),
                          ],

                          // Mô tả
                          const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 10),
                          Text(
                            product.description,
                            style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[800]),
                          ),
                          
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // --- Nút Add to Cart (Đã gắn sự kiện) ---
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isAddingToCart ? null : () => _handleAddToCart(product),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _isAddingToCart
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Add to Cart",
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}