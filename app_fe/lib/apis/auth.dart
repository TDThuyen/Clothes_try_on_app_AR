import 'package:dio/dio.dart';
import '../models/auth/login_response.dart';
import '../models/auth/refresh_token_response.dart';
import '../models/auth/register_response.dart';
import '../models/auth/verify_otp_response.dart';

class AuthService {
  final String baseUrl;
  late final Dio _dio;

  AuthService({required this.baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
  }

  // ===== Register =====
  Future<RegisterResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );
      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map<String, dynamic>) {
        final map = e.response!.data as Map<String, dynamic>;
        throw Exception(map['message'] ?? 'Unknown error');
      }
      throw Exception(e.message);
    }
  }

  // ===== Verify OTP =====
  Future<VerifyOtpResponse> verifyOtp({
    required int userId,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/verify-otp',
        data: {'userId': userId, 'otp': otp},
      );
      return VerifyOtpResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map<String, dynamic>) {
        final map = e.response!.data as Map<String, dynamic>;
        throw Exception(map['message'] ?? 'Unknown error');
      }
      throw Exception(e.message);
    }
  }

  // ===== Login =====
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map<String, dynamic>) {
        final map = e.response!.data as Map<String, dynamic>;
        throw Exception(map['message'] ?? 'Unknown error');
      }
      throw Exception(e.message);
    }
  }

  // ===== Refresh Token =====
  Future<RefreshTokenResponse> refreshToken({required String refreshToken}) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      return RefreshTokenResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map<String, dynamic>) {
        final map = e.response!.data as Map<String, dynamic>;
        throw Exception(map['message'] ?? 'Unknown error');
      }
      throw Exception(e.message);
    }
  }
}
