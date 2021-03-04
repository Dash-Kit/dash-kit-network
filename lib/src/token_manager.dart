import 'dart:async';

import 'package:dash_kit_network/src/models/token_pair.dart';
import 'package:dash_kit_network/src/models/token_refresher.dart';
import 'package:rxdart/rxdart.dart';

/// Component for storing tokens within app session
/// and updating it with TokenRefresher
class TokenManager {
  /// `tokenRefresher` - function for updating tokens through the API
  /// `tokenPair` - initial token pair from prevous user session
  TokenManager({
    required TokenRefresher tokenRefresher,
    required this.tokenPair,
  }) : _tokenRefresher = tokenRefresher;

  final TokenRefresher _tokenRefresher;
  final _onTokenPairRefreshed = PublishSubject<TokenPair>();
  final _onTokenPairRefreshingFailed = PublishSubject();

  TokenPair tokenPair;
  bool _isRefreshing = false;
  bool _isRefreshingFailed = false;

  /// Manual tokens updating. Needed when tokens was received for example
  /// through sign in API method or reset password
  void updateTokens(TokenPair tokenPair) {
    this.tokenPair = tokenPair;
  }

  /// Getting actual token pair even on the refresh tokens process
  Future<TokenPair> getTokens() {
    if (_isRefreshingFailed) {
      return refreshTokens();
    }

    if (_isRefreshing) {
      return _onTokenPairRefreshed.first;
    }

    return Future.value(tokenPair);
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

    return _tokenRefresher(tokenPair).then((tokenPair) {
      _onTokensRefreshingCompleted(tokenPair);
      return tokenPair;
    }).catchError((error) {
      _isRefreshingFailed = true;

      _onTokenPairRefreshingFailed.add(error);
      throw error;
    });
  }

  void _onTokensRefreshingCompleted(TokenPair tokenPair) {
    _isRefreshingFailed = false;

    this.tokenPair = tokenPair;
    _onTokenPairRefreshed.add(tokenPair);

    _isRefreshing = false;
  }
}
