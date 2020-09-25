import 'package:dio/dio.dart';
import 'package:dash_kit_network/src/models/token_pair.dart';
import 'package:dash_kit_network/src/refresh_tokens_delegate.dart';
import 'package:dash_kit_network/src/token_storage.dart';

/// RefreshTokensDelegate that includes base implementation for
/// token refreshing operations. Override the implementations that
/// does not fit in your API requirements
abstract class BaseRefreshTokensDelegate extends RefreshTokensDelegate {
  BaseRefreshTokensDelegate(this.tokenStorage);

  final TokenStorage tokenStorage;

  /// Request for tokens refreshing
  @override
  Future<TokenPair> refreshTokens(Dio dio, TokenPair tokenPair);

  /// This method will be called when API cannot update token pair
  /// because of the refresh token is expired.
  /// User should be redirected to sign-in screen in that case
  @override
  void onTokensRefreshingFailed();

  @override
  Future<TokenPair> loadTokensFromStorage() async {
    final accessToken = await tokenStorage.getAccessToken();
    final refreshToken = await tokenStorage.getRefreshToken();

    return TokenPair(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  @override
  Future<void> onTokensUpdated(TokenPair tokenPair) {
    return tokenStorage.saveTokens(
      accessToken: tokenPair.accessToken,
      refreshToken: tokenPair.refreshToken,
    );
  }

  @override
  bool isAccessTokenExpired(DioError error) {
    return error.response?.statusCode == 401;
  }

  @override
  bool isRefreshTokenExpired(DioError error) {
    return error.response?.statusCode == 401;
  }

  @override
  RequestOptions appendAccessTokenToRequest(
    Options options,
    TokenPair tokenPair,
  ) {
    options.headers['Authorization'] = 'Bearer ${tokenPair?.accessToken}';
    return options;
  }
}
