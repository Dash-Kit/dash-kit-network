import 'dart:async';

import 'package:dash_kit_network/src/models/token_pair.dart';
import 'package:dash_kit_network/src/models/token_refresher.dart';
import 'package:dash_kit_network/src/refresh_tokens_delegate.dart';
import 'package:rxdart/rxdart.dart';

/// Component for storing tokens within app session
/// and updating it with TokenRefresher
class TokenManager {
  /// `tokenRefresher` - function for updating tokens through the API
  /// `tokenPair` - initial token pair from prevous user session
  TokenManager({
    required this.delegate,
    required this.tokenRefresher,
  });

  final _onTokenPairRefreshed = PublishSubject<TokenPair>();
  final _onTokenPairRefreshingFailed = PublishSubject();
  final RefreshTokensDelegate delegate;
  final TokenRefresher tokenRefresher;

  bool _isRefreshing = false;
  bool _isRefreshingFailed = false;

  /// Manual tokens updating. Needed when tokens was received for example
  /// through sign in API method or reset password
  Future<void> updateTokens(TokenPair tokenPair) {
    return delegate.updateTokens(tokenPair);
  }

  /// Getting actual token pair even on the refresh tokens process
  Future<TokenPair> getTokens() {
    if (_isRefreshingFailed) {
      return refreshTokens();
    }

    if (_isRefreshing) {
      return _onTokenPairRefreshed.first;
    }

    return delegate.getTokens();
  }

  /// Tokens refreshed event
  Stream<TokenPair> onTokensRefreshed() {
    return _onTokenPairRefreshed;
  }

  /// Failed token refreshing event
  Future<void> onTokensRefreshingFailed() {
    return _onTokenPairRefreshingFailed.first;
  }

  /// Method for tokens refreshing
  Future<TokenPair> refreshTokens() async {
    if (!_isRefreshingFailed && _isRefreshing) {
      return _onTokenPairRefreshed.first;
    }

    _isRefreshing = true;
    _isRefreshingFailed = false;

    final tokenPair = await delegate.getTokens();

    return tokenRefresher(tokenPair)
        .then(_onTokensRefreshingCompleted)
        .catchError((error) {
      _isRefreshingFailed = true;

      _onTokenPairRefreshingFailed.add(error);
      throw error;
    });
  }

  TokenPair _onTokensRefreshingCompleted(TokenPair tokenPair) {
    _isRefreshingFailed = false;

    _onTokenPairRefreshed.add(tokenPair);

    _isRefreshing = false;

    return tokenPair;
  }
}
