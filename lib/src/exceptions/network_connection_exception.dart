import 'package:dio/dio.dart';

class NetworkConnectionException implements Exception {
  NetworkConnectionException(this.error, [this.stackTrace]);

  final DioError error;
  final dynamic stackTrace;

  @override
  String toString() {
    return 'No internet connection';
  }
}
