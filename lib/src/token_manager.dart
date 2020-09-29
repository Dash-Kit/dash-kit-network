import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dash_kit_network/src/models/token_pair.dart';
import 'package:dash_kit_network/src/models/token_refresher.dart';
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
    _tokenPair = tokenPair ??
        const TokenPair(
          accessToken: '',
          refreshToken: '',
        );
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
  Future<TokenPair> getTokens() {
    if (_isRefreshingFailed) {
      return refreshTokens();
    }

    if (_isRefreshing) {
      return _onTokenPairRefreshed.first;
    }

    return Future.value(_tokenPair);
  }

  /// Tokens refreshed event
  Future<TokenPair> onTokensRefreshed() {
    return _onTokenPairRefreshed.first;
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

    return _tokenRefresher(_tokenPair).then((tokenPair) {
      _onTokensRefreshingCompleted(tokenPair);
      return tokenPair;
    }).catchError((error) {
      _isRefreshingFailed = true;

      if (error is RetryError && error.errors?.last?.error != null) {
        final requestError = error.errors.last.error;

        _onTokenPairRefreshingFailed.add(requestError);
        throw requestError;
      }

      throw error;
    });
  }

  void _onTokensRefreshingCompleted(TokenPair tokenPair) {
    _isRefreshingFailed = false;

    _tokenPair = tokenPair;
    _onTokenPairRefreshed.add(tokenPair);

    _isRefreshing = false;
  }
}
