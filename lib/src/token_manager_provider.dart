import 'package:dash_kit_network/dash_kit_network.dart';
import 'package:dash_kit_network/src/token_manager.dart';

class TokenManagerProvider {
  TokenManagerProvider(this.delegate, this.dio);

  TokenManager? _tokenManagerInstance;

  final RefreshTokensDelegate? delegate;
  final Dio dio;

  Future<TokenManager> getTokenManager() async {
    if (delegate == null) {
      throw const RefreshTokensDelegateMissingException();
    }

    if (_tokenManagerInstance == null) {
      final tokenPair = await delegate!.loadTokensFromStorage();

      _tokenManagerInstance = TokenManager(
        tokenRefresher: (tokenPair) async {
          final newTokenPair = await delegate!.refreshTokens(dio, tokenPair);
          await delegate!.onTokensUpdated(newTokenPair);
          return newTokenPair;
        },
        tokenPair: tokenPair,
      );
    }

    return Future.value(_tokenManagerInstance);
  }
}
