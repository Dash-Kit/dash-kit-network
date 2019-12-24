import 'package:flutter_platform_network/flutter_platform_network.dart';

class TestRefreshTokensDelegate extends BaseRefreshTokensDelegate {
  TestRefreshTokensDelegate(
    TokenStorage tokenStorage, {
    this.onTokenRefreshingFailedCallback,
  }) : super(tokenStorage);

  final void Function() onTokenRefreshingFailedCallback;

  @override
  void onTokensRefreshingFailed() {
    if (onTokenRefreshingFailedCallback != null) {
      onTokenRefreshingFailedCallback();
    }
  }

  @override
  Future<TokenPair> refreshTokens(Dio dio, TokenPair tokenPair) {
    return dio.post('refresh_tokens').then(
          (response) => TokenPair(
            accessToken:
                response?.data != null ? response.data['access_token'] : null,
            refreshToken:
                response?.data != null ? response.data['refresh_token'] : null,
          ),
        );
  }
}
