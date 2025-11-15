class CartItem {
  final int id;
  final int productId;
  final String name;
  final double price;
  final String size;
  final String? imageUrl;
  int quantity;
  bool isSelected;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.size,
    required this.imageUrl,
    required this.quantity,
    required this.isSelected,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final product = json["product"];

    return CartItem(
      id: json["id"],
      productId: json["productId"],
      name: product["name"],
      price: (json["price"] ?? product["price"] ?? 0).toDouble(),
      size: json["size"] ?? "",
      imageUrl: product["imageUrl"],
      quantity: json["quantity"] ?? 1,
      isSelected: json["isSelected"] ?? false,
    );
  }
}
