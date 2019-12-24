import 'package:dio/dio.dart';

class RequestErrorException implements Exception {
  RequestErrorException(this.error);

  final DioError error;

  @override
  String toString() {
    return 'Network request error has occurred';
  }
}
