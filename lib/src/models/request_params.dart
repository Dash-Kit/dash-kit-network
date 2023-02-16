import 'package:dash_kit_network/src/api_client.dart';
import 'package:dash_kit_network/src/models/http_header.dart';
import 'package:dash_kit_network/src/models/response_mapper.dart';
import 'package:dio/dio.dart';

class RequestParams<T> {
  const RequestParams({
    required this.method,
    required this.path,
    required this.headers,
    required this.responseMapper,
    required this.isAuthorisedRequest,
    required this.validate,
    this.body,
    this.queryParams = const {},
    this.responseType = ResponseType.json,
    this.receiveTimeout,
    this.sendTimeout,
    this.contentType = Headers.jsonContentType,
    this.cancelToken,
  });

  final HttpMethod method;
  final String path;
  final List<HttpHeader> headers;
  final ResponseMapper<T> responseMapper;
  final bool isAuthorisedRequest;
  final bool validate;
  final dynamic body;
  final Map<String, dynamic> queryParams;
  final ResponseType responseType;
  final Duration? receiveTimeout;
  final Duration? sendTimeout;
  final String contentType;
  final CancelToken? cancelToken;
}
