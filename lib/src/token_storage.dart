import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Component for secure authorization tokens storage
class TokenStorage {
  static const _accessTokenKey = 'TS_ACCESS_TOKEN';
  static const _refreshTokenKey = 'TS_REFRESH_TOKEN';

  final storage = const FlutterSecureStorage();

  Future<bool> isAuthorized() async {
    final String? token = await storage.read(key: _accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<String?> getAccessToken() async {
    return storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async{
    return storage.read(key: _refreshTokenKey);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) {
    return Future.wait([
      storage.write(key: _accessTokenKey, value: accessToken),
      storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  Future<void> clearTokens() {
    return storage.deleteAll();
  }
}
