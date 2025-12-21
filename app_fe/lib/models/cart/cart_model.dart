class CartModel {
  final int id;
  final List<CartItemModel> items;

  CartModel({required this.id, required this.items});

  factory CartModel.fromJson(Map<String, dynamic> json) {
    // Xử lý an toàn nếu danh sách rỗng
    var list = json['cartItems'] as List? ?? [];
    List<CartItemModel> itemsList = list.map((i) => CartItemModel.fromJson(i)).toList();

    return CartModel(
      id: json['id'] ?? 0,
      items: itemsList,
    );
  }
}

class CartItemModel {
  final int id;
  final int productId;
  final int quantity;
  final String? size;
  final double price;
  final bool isSelected;
  final ProductInfo? product;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.quantity,
    this.size,
    required this.price,
    required this.isSelected,
    this.product,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'],
      productId: json['productId'],
      quantity: json['quantity'] ?? 1,
      size: json['size'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      isSelected: json['isSelected'] ?? false,
      product: json['product'] != null ? ProductInfo.fromJson(json['product']) : null,
    );
  }
}

class ProductInfo {
  final String name;
  final String imageUrl;

  ProductInfo({required this.name, required this.imageUrl});

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
