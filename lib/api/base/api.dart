import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_platform_network/api/base/api_environment.dart';
import 'package:flutter_platform_network/api/base/http_header.dart';
import 'package:flutter_platform_network/api/base/response_mapper.dart';
import 'package:flutter_platform_network/api/base/exceptions/network_connection_exception.dart';
import 'package:flutter_platform_network/api/base/exceptions/request_error_exception.dart';
import 'package:flutter_platform_network/api/base/interceptors/refresh_token_interceptor.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:rxdart/rxdart.dart';

enum HttpMethod { GET, POST, PUT, PATCH, DELETE }

abstract class API {
  final APIEnvironment environment;
  final Dio dio;

  API({
    @required this.environment,
    @required this.dio,
  });

  Observable<T> get<T>({
    @required String path,
    Map<String, dynamic> queryParams,
    List<HttpHeader> headers = const [],
    ResponseMapper<T> responseMapper,
    bool isAuthorisedRequest = true,
    bool logResponse = true,
    bool validate = true,
  }) {
    return _request(
      method: HttpMethod.GET,
      path: path,
      headers: headers,
      queryParams: _filterNullParams(queryParams ?? Map()),
      responseMapper: responseMapper,
      logResponse: logResponse,
      validate: validate,
      isAuthorisedRequest: isAuthorisedRequest,
    );
  }

  Observable<T> post<T>({
    @required String path,
    List<HttpHeader> headers = const [],
    ResponseMapper<T> responseMapper,
    dynamic body,
    bool isAuthorisedRequest = true,
    bool logResponse = true,
    bool validate = true,
    ResponseType responseType = ResponseType.json,
  }) {
    return _request(
      method: HttpMethod.POST,
      path: path,
      headers: headers,
      responseMapper: responseMapper,
      body: body,
      responseType: responseType,
      logResponse: logResponse,
      validate: validate,
      isAuthorisedRequest: isAuthorisedRequest,
    );
  }

  Observable<T> put<T>({
    @required String path,
    List<HttpHeader> headers = const [],
    ResponseMapper<T> responseMapper,
    dynamic body,
    bool isAuthorisedRequest = true,
    bool logResponse = true,
    bool validate = true,
    ResponseType responseType = ResponseType.json,
  }) {
    return _request(
      method: HttpMethod.PUT,
      path: path,
      headers: headers,
      responseMapper: responseMapper,
      body: body,
      responseType: responseType,
      logResponse: logResponse,
      validate: validate,
      isAuthorisedRequest: isAuthorisedRequest,
    );
  }

  Observable<T> patch<T>({
    @required String path,
    List<HttpHeader> headers = const [],
    ResponseMapper<T> responseMapper,
    dynamic body,
    bool isAuthorisedRequest = true,
    bool logResponse = true,
    bool validate = true,
    ResponseType responseType = ResponseType.json,
  }) {
    return _request(
      method: HttpMethod.PATCH,
      path: path,
      headers: headers,
      responseMapper: responseMapper,
      body: body,
      responseType: responseType,
      logResponse: logResponse,
      validate: validate,
      isAuthorisedRequest: isAuthorisedRequest,
    );
  }

  Observable<T> delete<T>({
    @required String path,
    List<HttpHeader> headers = const [],
    ResponseMapper<T> responseMapper,
    dynamic body,
    bool isAuthorisedRequest = true,
    bool logResponse = true,
    bool validate = true,
  }) {
    return _request(
      method: HttpMethod.DELETE,
      path: path,
      responseMapper: responseMapper,
      body: body,
      headers: headers,
      logResponse: logResponse,
      validate: validate,
      isAuthorisedRequest: isAuthorisedRequest,
    );
  }

  Observable<T> _request<T>({
    @required HttpMethod method,
    @required String path,
    List<HttpHeader> headers = const [],
    ResponseMapper<T> responseMapper,
    dynamic body,
    Map<String, dynamic> queryParams,
    ResponseType responseType,
    bool isAuthorisedRequest = true,
    bool logResponse = true,
    bool validate = true,
  }) {
    return _createRequest(
      method: method,
      url: _url(path),
      body: body,
      queryParams: queryParams,
      responseType: responseType,
      headers: _headers(headers),
      validate: validate,
      isAuthorisedRequest: isAuthorisedRequest,
    ).map(responseMapper);
  }

  String _url(String path) => environment.baseUrl + path;

  Map<String, String> _headers(List<HttpHeader> headers) =>
      headers.fold(Map(), (prev, curr) {
        prev[curr.name] = curr.value;
        return prev;
      });

  Observable<Response> _createRequest({
    HttpMethod method,
    String url,
    Map<String, dynamic> headers,
    body,
    Map<String, dynamic> queryParams,
    ResponseType responseType,
    bool validate,
    bool isAuthorisedRequest = true,
  }) {
    StreamController<Response> controller;

    var cancelToken = CancelToken();
    var options = Options(
      headers: headers,
      responseType: responseType,
      extra: {AUTHORISED_REQUEST: isAuthorisedRequest},
    );

    var onListen = () {
      Future<Response> request;

      switch (method) {
        case HttpMethod.GET:
          request = dio.get(
            url,
            queryParameters: queryParams,
            options: options,
            cancelToken: cancelToken,
          );
          break;

        case HttpMethod.POST:
          request = dio.post(
            url,
            data: body,
            options: options,
            cancelToken: cancelToken,
          );
          break;

        case HttpMethod.PUT:
          request = dio.put(
            url,
            data: body,
            options: options,
            cancelToken: cancelToken,
          );
          break;

        case HttpMethod.PATCH:
          request = dio.patch(
            url,
            data: body,
            options: options,
            cancelToken: cancelToken,
          );
          break;

        case HttpMethod.DELETE:
          request = dio.delete(
            url,
            data: body,
            options: options,
            cancelToken: cancelToken,
          );
          break;
      }

      request.then((response) {
        controller.add(response);
        controller.close();
      }).catchError((error) {
        if (error is DioError) {
          final response = error.response;
          final type = error.type;

          if (!validate && response != null) {
            controller.add(error.response);
          } else if (type == DioErrorType.CONNECT_TIMEOUT ||
              type == DioErrorType.RECEIVE_TIMEOUT ||
              type == DioErrorType.SEND_TIMEOUT ||
              error?.error is SocketException) {
            controller.addError(NetworkConnectionException());
          } else {
            controller.addError(RequestErrorException());
          }

          controller.close();
          return;
        }

        controller.addError(error);
        controller.close();
      });
    };

    var onCancel = () => cancelToken.cancel();

    controller = StreamController<Response>(
      onListen: onListen,
      onCancel: onCancel,
    );

    return Observable(controller.stream);
  }

  FormData getFormDataFromImageFile({String fieldName, File file}) {
    FormData formData = FormData();
    formData.add(
      fieldName,
      UploadFileInfo(
        file,
        basename(file.path),
        contentType: ContentType("image", "jpeg", charset: "utf-8"),
      ),
    );

    return formData;
  }

  Map<String, dynamic> _filterNullParams(Map<String, dynamic> queryParams) {
    if (queryParams.isNotEmpty) {
      queryParams.removeWhere((key, value) => value == null);
    }

    return queryParams;
  }
}
