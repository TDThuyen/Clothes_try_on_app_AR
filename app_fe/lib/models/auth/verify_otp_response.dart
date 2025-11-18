class VerifyOtpData {
  final bool verified;

  VerifyOtpData({required this.verified});

  factory VerifyOtpData.fromJson(Map<String, dynamic> json) {
    return VerifyOtpData(
      verified: json['verified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verified': verified,
    };
  }
}

class VerifyOtpResponse {
  final String message;
  final bool success;
  final VerifyOtpData data;

  VerifyOtpResponse({
    required this.message,
    required this.success,
    required this.data,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      message: json['message'],
      success: json['success'],
      data: VerifyOtpData.fromJson(json['data']),
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
