import 'package:flutter_platform_network/flutter_platform_network.dart';
import 'package:flutter_platform_network/src/token_manager.dart';
import 'package:rxdart/rxdart.dart';

class TokenManagerProvider {
  TokenManagerProvider(this.delegate, this.dio);

  TokenManager _tokenManagerInstance;
  final _tokenManager = ReplaySubject<TokenManager>(maxSize: 1);

  final RefreshTokensDelegate delegate;
  final Dio dio;

  Observable<TokenManager> getTokenManager() {
    if (delegate == null) {
      throw RefreshTokensDelegateMissingException();
    }

    if (_tokenManagerInstance == null) {
      _tokenManagerInstance = TokenManager(tokenRefresher: (tokenPair) {
        return Observable.fromFuture(delegate.refreshTokens(dio, tokenPair))
            .doOnData((tokenPair) => delegate.onTokensUpdated(tokenPair));
      });

      delegate
          .loadTokensFromStorage()
          .then(_tokenManagerInstance.updateTokens)
          .then((_) => _tokenManager.add(_tokenManagerInstance));
    }

    return _tokenManager;
  }
}
