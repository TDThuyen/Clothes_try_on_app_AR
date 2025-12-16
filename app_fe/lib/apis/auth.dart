import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/auth/login_response.dart';
import '../models/auth/refresh_token_response.dart';
import '../models/auth/register_response.dart';
import '../models/auth/verify_otp_response.dart';
import '../services/storage_service.dart';
import '../models/auth/user_model.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  final String baseUrl = AppConfig.baseUrl;
  final StorageService _storageService = StorageService();

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

  Future<UserModel?> getProfile() async {
    final url = Uri.parse('$baseUrl/auth/me');

    try {
      final token = await _storageService.read('accessToken'); 

      if (token == null) return null;

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Gửi Token lên Header
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend trả về: { "status": "success", "data": {...} }
        // Hoặc trả trực tiếp {...} tùy format
        // Code mẫu này giả định data nằm trong key 'data'
        if (data['data'] != null) {
          return UserModel.fromJson(data['data']);
        }
        return UserModel.fromJson(data); // Fallback nếu trả trực tiếp
      } else {
        return null;
      }
    } catch (e) {
      print('Get profile error: $e');
      return null;
    }
  }

  // 2. Đăng xuất (Logout)
  Future<void> logout() async {
    // Xóa token khỏi máy
    await _storageService.delete('accessToken');
    await _storageService.delete('refreshToken');
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
