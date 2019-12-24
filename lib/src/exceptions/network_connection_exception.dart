import 'package:dio/dio.dart';

class NetworkConnectionException implements Exception {
  NetworkConnectionException(this.error);

  final DioError error;

  @override
  String toString() {
    return 'No internet connection';
  }
}
