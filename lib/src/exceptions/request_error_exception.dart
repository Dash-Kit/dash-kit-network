import 'package:dio/dio.dart';

class RequestErrorException implements Exception {
  RequestErrorException(this.error, [this.stackTrace]);

  final DioError error;
  final dynamic stackTrace;

  @override
  String toString() {
    return 'Network request error has occurred';
  }
}
