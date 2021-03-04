import 'package:dash_kit_network/dash_kit_network.dart';

class TestRefreshTokensDelegate extends BaseRefreshTokensDelegate {
  TestRefreshTokensDelegate(
    TokenStorage tokenStorage, {
    this.onTokenRefreshingFailedCallback,
  }) : super(tokenStorage);

  final void Function()? onTokenRefreshingFailedCallback;

  @override
  void onTokensRefreshingFailed() {
    onTokenRefreshingFailedCallback?.call();
  }

  @override
  Future<TokenPair> refreshTokens(Dio dio, TokenPair tokenPair) {
    return dio.post('refresh_tokens').then(
          (response) => TokenPair(
            accessToken:
                response.data != null ? response.data['access_token'] : null,
            refreshToken:
                response.data != null ? response.data['refresh_token'] : null,
          ),
        );
  }
}
