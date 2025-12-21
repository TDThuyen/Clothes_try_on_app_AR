class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final int categoryId;
  final String gender;
  final String availableSizes;
  final String color;
  final String imageUrl;
  final double ratingAvg;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.gender,
    required this.availableSizes,
    required this.color,
    required this.imageUrl,
    required this.ratingAvg,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? 'Không có mô tả',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      categoryId: json['categoryId'] ?? 0,
      gender: json['gender'] ?? 'Unisex',
      availableSizes: json['availableSizes'] ?? '',
      color: json['color'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
