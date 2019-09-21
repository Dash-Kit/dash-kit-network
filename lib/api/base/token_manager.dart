import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static const _PREF_AUTH_TOKEN = 'PREF_AUTH_TOKEN';
  static const _PREF_AUTH_TIMESTAMP = 'PREF_AUTH_TIMESTAMP';
  static const _PREF_REFRESH_TOKEN = 'PREF_REFRESH_TOKEN';
  static const _PREF_REFRESH_TIMESTAMP = 'PREF_REFRESH_TIMESTAMP';

  final storage = FlutterSecureStorage();

  TokenManager();

  Future<bool> authorized() async {
    final token = await storage.read(key: _PREF_AUTH_TOKEN);
    return token != null && token.isNotEmpty;
  }

  Future<String> getAuthToken() {
    return storage.read(key: _PREF_AUTH_TOKEN);
  }

  Future<String> getRefreshToken() {
    return storage.read(key: _PREF_REFRESH_TOKEN);
  }

  void saveTokens({
    String authToken,
    int authTimeStamp,
    String refreshToken,
    int refreshTimeStamp,
  }) {
    storage.write(key: _PREF_AUTH_TOKEN, value: authToken);
    storage.write(key: _PREF_AUTH_TIMESTAMP, value: authTimeStamp.toString());
    storage.write(key: _PREF_REFRESH_TOKEN, value: refreshToken);
    storage.write(
        key: _PREF_REFRESH_TIMESTAMP, value: refreshTimeStamp.toString());
  }

  Future<void> clearTokens() {
    return storage.deleteAll();
  }
}
