import 'package:dash_kit_network/dash_kit_network.dart';
import 'package:dash_kit_network/src/token_manager.dart';
import 'package:rxdart/rxdart.dart';

class TokenManagerProvider {
  TokenManagerProvider(this.delegate, this.dio);

  TokenManager _tokenManagerInstance;
  final _tokenManager = ReplaySubject<TokenManager>(maxSize: 1);

  final RefreshTokensDelegate delegate;
  final Dio dio;

  Stream<TokenManager> getTokenManager() {
    if (delegate == null) {
      throw RefreshTokensDelegateMissingException();
    }

    if (_tokenManagerInstance == null) {
      _tokenManagerInstance = TokenManager(tokenRefresher: (tokenPair) {
        return Stream.fromFuture(delegate.refreshTokens(dio, tokenPair))
            .asyncMap((tokenPair) async {
          await delegate.onTokensUpdated(tokenPair);
          return Future.value(tokenPair);
        });
      });

      delegate
          .loadTokensFromStorage()
          .then(_tokenManagerInstance.updateTokens)
          .then((_) => _tokenManager.add(_tokenManagerInstance));
    }

    return _tokenManager;
  }
}
