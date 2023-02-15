import 'package:flutter/material.dart';

@immutable
class TokenPair {
  const TokenPair({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  @override
  int get hashCode => accessToken.hashCode ^ refreshToken.hashCode;

  @override
  String toString() {
    return 'Token Pair: '
        'access token = $accessToken, '
        'refresh token = $refreshToken';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenPair &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken &&
          refreshToken == other.refreshToken;
}
