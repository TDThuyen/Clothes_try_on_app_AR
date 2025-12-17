class UserModel {
  final int id;
  final String email;
  final String name;
  final String? address;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.address,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? 'No Name',
      address: json['address'], // Có thể null
      avatarUrl: json['avatarUrl'], // Có thể null
    );
  }
}
