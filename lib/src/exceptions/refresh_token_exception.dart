import 'package:dash_kit_network/dash_kit_network.dart';

class RefreshTokenException implements Exception {
  const RefreshTokenException(this.exception);

  final DioException exception;

  @override
  String toString() {
    return 'An error occurred during refreshing tokens';
  }
}
