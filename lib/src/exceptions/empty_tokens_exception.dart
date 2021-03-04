class EmptyTokensException implements Exception {
  const EmptyTokensException({
    required this.accessToken,
    required this.refreshToken,
  });

  final String? accessToken;
  final String? refreshToken;

  @override
  String toString() {
    return 'Either access or refresh token is empty:\n'
        'Access token: $accessToken\nRefresh token: $refreshToken';
  }
}
