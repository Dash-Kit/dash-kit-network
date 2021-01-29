import 'package:dio/dio.dart';

/// Delegate that provides a set methods for controlling
/// the process of error handling through all requests
abstract class ErrorHandlerDelegate {
  /// This method will be called for error handling purposes
  void handleError(DioError error, [dynamic stackTrace]);

  /// Calls to determine if the request failed
  /// and we can proceed it
  bool canHandleError(DioError error);
}
