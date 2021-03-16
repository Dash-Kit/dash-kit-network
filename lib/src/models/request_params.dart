import 'package:dio/dio.dart';
import 'package:dash_kit_network/src/api_client.dart';
import 'package:dash_kit_network/src/models/http_header.dart';
import 'package:dash_kit_network/src/models/response_mapper.dart';

class RequestParams<T> {
  const RequestParams({
    this.method,
    this.path,
    this.headers,
    this.responseMapper,
    this.body,
    this.queryParams,
    this.responseType,
    this.isAuthorisedRequest,
    this.validate,
    this.connectTimeout,
    this.receiveTimeout,
    this.sendTimeout,
    this.contentType,
  });

  final HttpMethod method;
  final String path;
  final List<HttpHeader> headers;
  final ResponseMapper<T> responseMapper;
  final dynamic body;
  final Map<String, dynamic> queryParams;
  final ResponseType responseType;
  final bool isAuthorisedRequest;
  final bool validate;
  final int connectTimeout;
  final int receiveTimeout;
  final int sendTimeout;
  final String contentType;
}
