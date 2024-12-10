import 'dart:io';

import 'package:dash_kit_network/src/error_handler_delegate.dart';
import 'package:dash_kit_network/src/exceptions/network_connection_exception.dart';
import 'package:dash_kit_network/src/exceptions/refresh_token_exception.dart';
import 'package:dash_kit_network/src/exceptions/refresh_tokens_delegate_missing_exception.dart';
import 'package:dash_kit_network/src/exceptions/request_error_exception.dart';
import 'package:dash_kit_network/src/models/api_environment.dart';
import 'package:dash_kit_network/src/models/http_header.dart';
import 'package:dash_kit_network/src/models/request_params.dart';
import 'package:dash_kit_network/src/models/response_mapper.dart';
import 'package:dash_kit_network/src/models/token_pair.dart';
import 'package:dash_kit_network/src/refresh_tokens_delegate.dart';
import 'package:dash_kit_network/src/token_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Component for communication with an API.
///
/// Includes functionality for updating tokens if they are expired.
// ignore_for_file: long-parameter-list
abstract class ApiClient {
  ApiClient({
    required this.environment,
    required this.dio,
    this.delegate,
    this.commonHeaders = const [],
    this.errorHandlerDelegate,
  }) : _tokenManager = delegate == null
            ? null
            : TokenManager(
                delegate: delegate,
                tokenRefresher: (tokenPair) async {
                  final newTokenPair =
                      await delegate.refreshTokens(dio, tokenPair);
                  await delegate.updateTokens(newTokenPair);

                  return newTokenPair;
                },
              ) {
    dio.options.baseUrl = environment.baseUrl;
  }

  final ApiEnvironment environment;
  final Dio dio;
  final List<HttpHeader> commonHeaders;
  final ErrorHandlerDelegate? errorHandlerDelegate;
  final RefreshTokensDelegate? delegate;
  final TokenManager? _tokenManager;

  Future<T> get<T>({
    required String path,
    required ResponseMapper<T> responseMapper,
    bool? isAuthorisedRequest,
    bool? validate,
    List<HttpHeader> headers = const [],
    Map<String, dynamic> queryParams = const {},
    dynamic body,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    String contentType = Headers.jsonContentType,
    CancelToken? cancelToken,
  }) {
    return _request(RequestParams<T>(
      method: HttpMethod.get,
      path: path,
      headers: headers,
      queryParams: _filterNullParams(queryParams),
      responseMapper: responseMapper,
      body: body,
      validate: validate ?? environment.validateRequestsByDefault,
      isAuthorisedRequest:
          isAuthorisedRequest ?? environment.isRequestsAuthorisedByDefault,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      contentType: contentType,
      cancelToken: cancelToken,
    ));
  }

  Future<T> post<T>({
    required String path,
    required ResponseMapper<T> responseMapper,
    List<HttpHeader> headers = const [],
    Map<String, dynamic> queryParams = const {},
    ResponseType responseType = ResponseType.json,
    dynamic body,
    bool? isAuthorisedRequest,
    bool? validate,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    String contentType = Headers.jsonContentType,
    CancelToken? cancelToken,
  }) {
    return _request(RequestParams<T>(
      method: HttpMethod.post,
      path: path,
      headers: headers,
      queryParams: _filterNullParams(queryParams),
      responseMapper: responseMapper,
      body: body,
      responseType: responseType,
      validate: validate ?? environment.validateRequestsByDefault,
      isAuthorisedRequest:
          isAuthorisedRequest ?? environment.isRequestsAuthorisedByDefault,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      contentType: contentType,
      cancelToken: cancelToken,
    ));
  }

  Future<T> put<T>({
    required String path,
    required ResponseMapper<T> responseMapper,
    List<HttpHeader> headers = const [],
    Map<String, dynamic> queryParams = const {},
    ResponseType responseType = ResponseType.json,
    dynamic body,
    bool? isAuthorisedRequest,
    bool? validate,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    String contentType = Headers.jsonContentType,
    CancelToken? cancelToken,
  }) {
    return _request(RequestParams<T>(
      method: HttpMethod.put,
      path: path,
      headers: headers,
      queryParams: _filterNullParams(queryParams),
      responseMapper: responseMapper,
      body: body,
      responseType: responseType,
      validate: validate ?? environment.validateRequestsByDefault,
      isAuthorisedRequest:
          isAuthorisedRequest ?? environment.isRequestsAuthorisedByDefault,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      contentType: contentType,
      cancelToken: cancelToken,
    ));
  }

  Future<T> patch<T>({
    required String path,
    required ResponseMapper<T> responseMapper,
    List<HttpHeader> headers = const [],
    Map<String, dynamic> queryParams = const {},
    ResponseType responseType = ResponseType.json,
    dynamic body,
    bool? isAuthorisedRequest,
    bool? validate,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    String contentType = Headers.jsonContentType,
    CancelToken? cancelToken,
  }) {
    return _request(RequestParams<T>(
      method: HttpMethod.patch,
      path: path,
      headers: headers,
      queryParams: _filterNullParams(queryParams),
      responseMapper: responseMapper,
      body: body,
      responseType: responseType,
      validate: validate ?? environment.validateRequestsByDefault,
      isAuthorisedRequest:
          isAuthorisedRequest ?? environment.isRequestsAuthorisedByDefault,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      contentType: contentType,
      cancelToken: cancelToken,
    ));
  }

  Future<T> delete<T>({
    required String path,
    required ResponseMapper<T> responseMapper,
    List<HttpHeader> headers = const [],
    Map<String, dynamic> queryParams = const {},
    dynamic body,
    bool? isAuthorisedRequest,
    bool? validate,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    String contentType = Headers.jsonContentType,
    CancelToken? cancelToken,
  }) {
    return _request(RequestParams<T>(
      method: HttpMethod.delete,
      path: path,
      responseMapper: responseMapper,
      body: body,
      headers: headers,
      queryParams: _filterNullParams(queryParams),
      validate: validate ?? environment.validateRequestsByDefault,
      isAuthorisedRequest:
          isAuthorisedRequest ?? environment.isRequestsAuthorisedByDefault,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      contentType: contentType,
      cancelToken: cancelToken,
    ));
  }

  Future<void> updateAuthTokens(TokenPair tokenPair) {
    return _tokenManager!.updateTokens(tokenPair);
  }

  Future<void> clearAuthTokens() {
    const emptyTokenPair = TokenPair(
      accessToken: '',
      refreshToken: '',
    );

    return updateAuthTokens(emptyTokenPair);
  }

  Future<bool> isAuthorised() async {
    final tokenPair = await _tokenManager!.getTokens();

    return tokenPair.accessToken.isNotEmpty;
  }

  Future<T> _request<T>(RequestParams<T> params) async {
    if (params.isAuthorisedRequest && delegate == null) {
      throw const RefreshTokensDelegateMissingException();
    }

    final performRequest = (tokenPair) async {
      final response = await _createRequest(params, tokenPair);
      final transferableRequestOptions = RequestOptions(
        path: response.requestOptions.path,
        method: response.requestOptions.method,
      );
      final transferableResponse = Response(
        data: response.data,
        requestOptions: transferableRequestOptions,
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        isRedirect: response.isRedirect,
        redirects: response.redirects,
        extra: response.extra,
        headers: response.headers,
      );

      return compute(params.responseMapper, transferableResponse);
    };

    if (params.isAuthorisedRequest) {
      try {
        final tokens = await _tokenManager!.getTokens();

        return await performRequest(tokens);
      } catch (error) {
        if (error is DioException &&
            (delegate?.isAccessTokenExpired(error) ?? false)) {
          final refreshedTokens = await _tokenManager!
              .refreshTokens()
              .catchError((refreshError, st) {
            // ignore: deprecated_member_use_from_same_package
            delegate?.onTokensRefreshingFailed();

            return Error.throwWithStackTrace(
              RefreshTokenException(refreshError),
              st,
            );
          });

          return performRequest(refreshedTokens);
        }

        if (error is DioException &&
            (errorHandlerDelegate?.canHandleError(error) ?? false)) {
          errorHandlerDelegate!.handleError(error);
        }

        rethrow;
      }
    }

    return performRequest(null);
  }

  Map<String, String> _headers(List<HttpHeader> headers) =>
      headers.fold({}, (prev, curr) {
        prev[curr.name] = curr.value;

        return prev;
      });

  // ignore: long-method
  Future<Response<dynamic>> _createRequest(
    RequestParams params,
    TokenPair? tokenPair,
  ) async {
    final cancelToken = params.cancelToken;
    var options = Options(
      headers: _headers([...params.headers, ...commonHeaders]),
      responseType: params.responseType,
      receiveTimeout: params.receiveTimeout,
      sendTimeout: params.sendTimeout,
      contentType: params.contentType,
    );

    if (params.isAuthorisedRequest) {
      options = delegate?.appendAccessTokenToRequest(
            options,
            tokenPair,
          ) ??
          options;
    }

    try {
      return await _createDioRequest(
        params,
        options,
        cancelToken,
      );
    } catch (error, stackTrace) {
      if (error is DioException) {
        final response = error.response;
        final type = error.type;

        if (params.isAuthorisedRequest &&
            ((delegate?.isAccessTokenExpired(error) ?? false) ||
                (errorHandlerDelegate?.canHandleError(error) ?? false))) {
          rethrow;
        } else if (!params.validate && response != null) {
          return Future.value(response);
        } else if (_isNetworkConnectionError(type, error)) {
          return Error.throwWithStackTrace(
            NetworkConnectionException(error),
            stackTrace,
          );
        } else if (_isTimeoutConnectionError(type, error)) {
          return Error.throwWithStackTrace(
            TimeoutConnectionException(error),
            stackTrace,
          );
        } else {
          return Error.throwWithStackTrace(
            RequestErrorException(error),
            stackTrace,
          );
        }
      }

      rethrow;
    }
  }

  Future<Response<dynamic>> _createDioRequest(
    RequestParams params,
    Options options,
    CancelToken? cancelToken,
  ) {
    switch (params.method) {
      case HttpMethod.get:
        return dio.get(
          params.path,
          data: params.body,
          queryParameters: params.queryParams,
          options: options,
          cancelToken: cancelToken,
        );

      case HttpMethod.post:
        return dio.post(
          params.path,
          data: params.body,
          queryParameters: params.queryParams,
          options: options,
          cancelToken: cancelToken,
        );

      case HttpMethod.put:
        return dio.put(
          params.path,
          data: params.body,
          queryParameters: params.queryParams,
          options: options,
          cancelToken: cancelToken,
        );

      case HttpMethod.patch:
        return dio.patch(
          params.path,
          data: params.body,
          queryParameters: params.queryParams,
          options: options,
          cancelToken: cancelToken,
        );

      case HttpMethod.delete:
        return dio.delete(
          params.path,
          data: params.body,
          queryParameters: params.queryParams,
          options: options,
          cancelToken: cancelToken,
        );
    }
  }

  bool _isNetworkConnectionError(DioExceptionType type, DioException error) {
    return (type == DioExceptionType.unknown ||
            type == DioExceptionType.connectionError) &&
        error.error != null &&
        error.error is SocketException;
  }

  bool _isTimeoutConnectionError(DioExceptionType type, DioException error) {
    return type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.sendTimeout;
  }

  Map<String, dynamic> _filterNullParams(Map<String, dynamic> queryParams) {
    if (queryParams.isNotEmpty) {
      queryParams.removeWhere((key, value) => value == null);
    }

    return queryParams;
  }
}

enum HttpMethod { get, post, put, patch, delete }
