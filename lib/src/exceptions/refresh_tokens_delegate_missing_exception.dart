class RefreshTokensDelegateMissingException implements Exception {
  @override
  String toString() {
    return 'The refresh tokens delegate was not specified. '
        'Pass it to API client to have an ability '
        'to perform authorized requests.';
  }
}
