class RegisterData {
  final int id;
  final String email;

  RegisterData({required this.id, required this.email});

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      id: json['id'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
    };
  }
}

class RegisterResponse {
  final String message;
  final bool success;
  final RegisterData data;

  RegisterResponse({
    required this.message,
    required this.success,
    required this.data,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'],
      success: json['success'],
      data: RegisterData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'success': success,
      'data': data.toJson(),
    };
  }
}