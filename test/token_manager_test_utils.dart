import 'package:dash_kit_network/src/models/token_pair.dart';
import 'package:dash_kit_network/src/models/token_refresher.dart';
import 'package:dash_kit_network/src/token_manager.dart';

import 'api_client_test.mocks.dart';
import 'api_client_test_utils.dart';
import 'test_components/test_refresh_tokens_delegate.dart';

TokenManager createTokenManagerWithTokens(
  TokenRefresher tokenRefresher,
  TokenPair tokenPair, [
  MockTokenStorage? tokenStorage,
]) {
  tokenStorage ??= MockTokenStorage();
  final refreshTokenDelegate = TestRefreshTokensDelegate(tokenStorage);

  stubAccessToken(tokenStorage, tokenPair.accessToken);
  stubRefreshToken(tokenStorage, tokenPair.refreshToken);

  return TokenManager(
    tokenRefresher: tokenRefresher,
    delegate: refreshTokenDelegate,
  );
}
