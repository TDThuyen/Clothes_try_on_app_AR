import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String _defaultBaseUrl = 'http://10.0.2.2:3000';

  static String get baseUrl {
    return dotenv.get('BASE_URL', fallback: _defaultBaseUrl);
  }
}
