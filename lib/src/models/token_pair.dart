class TokenPair {
  const TokenPair({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  @override
  String toString() {
    return 'Token Pair: '
        'access token = $accessToken, '
        'refresh token = $refreshToken';
  }
}
