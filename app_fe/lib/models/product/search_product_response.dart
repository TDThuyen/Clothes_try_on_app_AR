class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int categoryId;
  final String? gender;
  final String? availableSizes;
  final String? color;
  final String? imageUrl;
  final String? arModelUrl;
  final double ratingAvg;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.categoryId,
    this.gender,
    this.availableSizes,
    this.color,
    this.imageUrl,
    this.arModelUrl,
    required this.ratingAvg,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    T? field<T>(String camel, String snake) {
      final value = json[camel] ?? json[snake];
      return value == null ? null : value as T;
    }

    return Product(
      id: field<int>('id', 'id') ?? 0,
      name: field<String>('name', 'name') ?? '',
      description: field<String>('description', 'description'),
      price: (field<num>('price', 'price') ?? 0).toDouble(),
      categoryId: field<int>('categoryId', 'category_id') ?? 0,
      gender: field<String>('gender', 'gender'),
      availableSizes: field<String>('availableSizes', 'available_sizes'),
      color: field<String>('color', 'color'),
      imageUrl: field<String>('imageUrl', 'image_url'),
      arModelUrl: field<String>('arModelUrl', 'ar_model_url'),
      ratingAvg: (field<num>('ratingAvg', 'rating_avg') ?? 0).toDouble(),
    );
  }

  String get formattedPrice {
    final intPrice = price.round();
    final formatted = intPrice.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '$formatted ₫';
  }
}

class ProductSearchResponse {
  final List<Product> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  ProductSearchResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory ProductSearchResponse.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    final items = itemsJson.map((e) => Product.fromJson(e)).toList();

    return ProductSearchResponse(
      items: items,
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}
