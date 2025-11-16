class Product {
  final int id;
  final String name;
  final String description;
  final int price;
  final int categoryId;
  final String gender;
  final String availableSizes;
  final String color;
  final String imageUrl;
  final String arModelUrl;
  final double ratingAvg;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.gender,
    required this.availableSizes,
    required this.color,
    required this.imageUrl,
    required this.arModelUrl,
    required this.ratingAvg,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      categoryId: json['category_id'],
      gender: json['gender'],
      availableSizes: json['available_sizes'],
      color: json['color'],
      imageUrl: json['image_url'],
      arModelUrl: json['ar_model_url'],
      ratingAvg: (json['rating_avg'] as num).toDouble(),
    );
  }

  String get formattedPrice =>
      '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} ₫';
}
