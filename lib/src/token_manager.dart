import 'package:flutter/material.dart';
import 'package:flutter_platform_network/src/models/token_pair.dart';
import 'package:flutter_platform_network/src/models/token_refresher.dart';
import 'package:rxdart/rxdart.dart';

/// Component for storing tokens within app session
/// and updating it with TokenRefresher
class TokenManager {
  /// `tokenRefresher` - function for updating tokens through the API
  /// `tokenPair` - initial token pair from prevous user session
  TokenManager({
    @required TokenRefresher tokenRefresher,
    TokenPair tokenPair,
  }) : _tokenRefresher = tokenRefresher {
    _tokenPair =
        tokenPair ?? const TokenPair(accessToken: '', refreshToken: '');
  }

  final TokenRefresher _tokenRefresher;
  final _onTokenPairRefreshed = ReplaySubject<TokenPair>();
  final _onTokenPairRefreshingFailed = ReplaySubject();

  TokenPair _tokenPair;
  bool _isRefreshing = false;
  bool _isRefreshingFailed = false;

  /// Manual tokens updating. Needed when tokens was received for example
  /// through sign in API method or reset password
  void updateTokens(TokenPair tokenPair) {
    _tokenPair = tokenPair;
  }

  /// Getting actual token pair even on the refresh tokens process
  Observable<TokenPair> getTokens() {
    if (_isRefreshingFailed) {
      return refreshTokens();
    }

    if (_isRefreshing) {
      return Observable(_onTokenPairRefreshed.stream).take(1);
    }

    return Observable.just(_tokenPair);
  }

  /// Tokens refreshed event observable
  Observable<TokenPair> onTokensRefreshed() {
    return Observable(_onTokenPairRefreshed.stream);
  }

  /// Failed token refreshing event observable
  Observable<void> onTokensRefreshingFailed() {
    return Observable(_onTokenPairRefreshingFailed.stream);
  }

  /// Method for tokens refreshing
  Observable<TokenPair> refreshTokens() {
    if (!_isRefreshingFailed && _isRefreshing) {
      return Observable(_onTokenPairRefreshed.stream).take(1);
    }

    _isRefreshing = true;
    _isRefreshingFailed = false;

    return Observable.retry(() => _tokenRefresher(_tokenPair), 2)
        .onErrorResume((error) {
      _isRefreshingFailed = true;

      _onTokenPairRefreshingFailed.add(error);

      return Observable.error(error);
    }).doOnData(_onTokensRefreshingCompleted);
  }

  void _onTokensRefreshingCompleted(TokenPair tokenPair) {
    _isRefreshingFailed = false;

    _tokenPair = tokenPair;
    _onTokenPairRefreshed.add(tokenPair);

    _isRefreshing = false;
  }
}
