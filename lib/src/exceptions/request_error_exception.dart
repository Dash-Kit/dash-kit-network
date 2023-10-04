import 'package:dio/dio.dart';

class RequestErrorException implements Exception {
  RequestErrorException(this.error);

  final DioException error;

  @override
  String toString() {
    return 'Network request error has occurred: '
        'Status code: ${error.response?.statusCode}\n'
        'Method: ${error.requestOptions.method}\n'
        'Url: ${error.response?.realUri}\n'
        'Response: ${error.response?.data}\n'
        'Error type: ${error.type}\n'
        'Original error:${error.error}';
  }
}
