class CreateOrderItemDto {
  final int productId;
  final int quantity;
  final String size;
  final double price;

  CreateOrderItemDto({
    required this.productId,
    required this.quantity,
    required this.size,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
        "productId": productId,
        "quantity": quantity,
        "size": size,
        "price": price,
      };
}

class CreateOrderDto {
  final String firstName;
  final String lastName;
  final String address;
  final int usedPoints;
  final List<CreateOrderItemDto> items;

  CreateOrderDto({
    required this.firstName,
    required this.lastName,
    required this.address,
    this.usedPoints = 0,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        "firstName": firstName,
        "lastName": lastName,
        "address": address,
        "usedPoints": usedPoints,
        "items": items.map((e) => e.toJson()).toList(),
      };
}
