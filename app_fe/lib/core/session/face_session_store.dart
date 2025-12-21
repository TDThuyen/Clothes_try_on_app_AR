class FaceSessionStore {
  static String? _sessionId;

  /// Lưu sessionId nhận từ Unity
  static void set(String sessionId) {
    _sessionId = sessionId;
  }

  /// Lấy sessionId hiện tại
  static String? get() {
    return _sessionId;
  }

  /// Kiểm tra có session hay chưa
  static bool hasSession() {
    return _sessionId != null && _sessionId!.isNotEmpty;
  }

  /// Clear khi user scan lại / logout
  static void clear() {
    _sessionId = null;
  }

  static Future<void> save(String message) async {}
}
