import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/auth/login_response.dart';
import '../models/auth/refresh_token_response.dart';
import '../models/auth/register_response.dart';
import '../models/auth/verify_otp_response.dart';
import '../services/storage_service.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  final String baseUrl = AppConfig.baseUrl;

  // ===== Register =====
  Future<RegisterResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return RegisterResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Server error';
        throw ApiException(message);
      }
    } catch (e) {
      throw ApiException('$e');
    }
  }

  // ===== Verify OTP =====
  Future<VerifyOtpResponse> verifyOtp({
    required int userId,
    required String otp,
  }) async {
    final url = Uri.parse('$baseUrl/auth/verify-otp');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VerifyOtpResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Server error';
        throw ApiException(message);
      }
    } catch (e) {
      throw ApiException('$e');
    }
  }

  // ===== Login =====
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LoginResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Server error';
        throw ApiException(message);
      }

    } catch (e) {
      throw ApiException('$e');
    }
  }

  // ===== Refresh Token =====
  Future<RefreshTokenResponse> refreshToken({
    required String refreshToken,
  }) async {
    final url = Uri.parse('$baseUrl/auth/refresh');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'refreshToken': refreshToken,
        }),
      );

      // ---- Success ----
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final refreshResp = RefreshTokenResponse.fromJson(data);
        final storageService = StorageService();
        await storageService.write('accessToken', refreshResp.data.accessToken);
        return refreshResp;
      } else {
        final errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Server error';
        throw ApiException(message);
      }
    } catch (e) {
      throw ApiException('$e');
    }
  }
}
