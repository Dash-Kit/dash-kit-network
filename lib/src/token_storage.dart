import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _accessTokenKey = 'TS_ACCESS_TOKEN';
const _refreshTokenKey = 'TS_REFRESH_TOKEN';

/// Component for secure authorization tokens storage
class TokenStorage {
  const TokenStorage(this.storage);

  final FlutterSecureStorage storage;

  Future<bool> isAuthorized() async {
    final String? token = await storage.read(key: _accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<String?> getAccessToken() async {
    return storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
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
    return Future.wait([
      storage.delete(key: _accessTokenKey),
      storage.delete(key: _refreshTokenKey),
    ]);
  }

  Future<void> clearAll() {
    return storage.deleteAll();
  }
}
