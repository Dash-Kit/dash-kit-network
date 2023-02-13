import 'package:dio/dio.dart';

class NetworkConnectionException implements Exception {
  NetworkConnectionException(this.error);

  final DioError? error;

  @override
  String toString() {
    return 'No internet connection';
  }
}

class TimeoutConnectionException implements Exception {
  TimeoutConnectionException(this.error);

  final DioError? error;

  @override
  String toString() {
    return 'Connection timed out';
  }
}
