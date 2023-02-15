import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _accessTokenKey = 'TS_ACCESS_TOKEN';
const _refreshTokenKey = 'TS_REFRESH_TOKEN';

/// Component for secure authorization tokens storage.
class TokenStorage {
  const TokenStorage(this.storage);

  final FlutterSecureStorage storage;

  Future<bool> isAuthorized() async {
    final token = await storage.read(key: _accessTokenKey);

    return token != null && token.isNotEmpty;
  }

  Future<String?> getAccessToken() {
    return storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() {
    return storage.read(key: _refreshTokenKey);
  }

  // We cannot use Future.wait() because web doesn't support it
  // https://github.com/mogol/flutter_secure_storage/issues/300#issuecomment-974063053.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await storage.write(key: _accessTokenKey, value: accessToken);
    await storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> clearTokens() async {
    await storage.delete(key: _accessTokenKey);
    await storage.delete(key: _refreshTokenKey);
  }

  Future<void> clearAll() {
    return storage.deleteAll();
  }
}
