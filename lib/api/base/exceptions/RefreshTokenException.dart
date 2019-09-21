class RefreshTokenException implements Exception {
  @override
  String toString() {
    return "Token expired";
  }
}