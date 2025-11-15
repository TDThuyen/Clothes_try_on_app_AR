import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ===== Write =====
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // ===== Read =====
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  // ===== Delete =====
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // ===== Read All =====
  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }

  // ===== Delete All =====
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
