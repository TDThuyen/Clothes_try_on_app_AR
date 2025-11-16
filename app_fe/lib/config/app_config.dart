import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // URL mặc định cho máy ảo Android
  static const String _defaultBaseUrl = 'http://10.0.2.2:3000';

  // Lấy BASE_URL từ file .env, nếu không có thì dùng giá trị mặc định
  static String get baseUrl {
    return dotenv.get('BASE_URL', fallback: _defaultBaseUrl);
  }
}
