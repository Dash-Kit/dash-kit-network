import 'dart:async';
import 'dart:io';

import 'package:dash_kit_network/src/error_handler_delegate.dart';
import 'package:dash_kit_network/src/exceptions/network_connection_exception.dart';
import 'package:dash_kit_network/src/exceptions/refresh_tokens_delegate_missing_exception.dart';
import 'package:dash_kit_network/src/exceptions/request_error_exception.dart';
import 'package:dash_kit_network/src/isolate_manager/isolate_manager_io/isolate_manager.dart'
    if (dart.library.html) 'package:dash_kit_network/src/isolate_manager/isolate_manager_web/isolate_manager.dart';
import 'package:dash_kit_network/src/models/api_environment.dart';
import 'package:dash_kit_network/src/models/http_header.dart';
import 'package:dash_kit_network/src/models/request_params.dart';
import 'package:dash_kit_network/src/models/response_mapper.dart';
import 'package:dash_kit_network/src/models/token_pair.dart';
import 'package:dash_kit_network/src/refresh_tokens_delegate.dart';
import 'package:dash_kit_network/src/token_manager.dart';
import 'package:dio/dio.dart';

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
    IsolateManager? externalIsolateManager,
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
              ), _isolateManager = externalIsolateManager ?? IsolateManager() {
    dio.options.baseUrl = environment.baseUrl;
    _isolateManager.start();
  }

  final ApiEnvironment environment;
  final Dio dio;
  final List<HttpHeader> commonHeaders;
  final ErrorHandlerDelegate? errorHandlerDelegate;
  final RefreshTokensDelegate? delegate;
  final TokenManager? _tokenManager;
  final IsolateManager _isolateManager;

  Future<T> get<T>({
    required String path,
    required ResponseMapper<T> responseMapper,
    bool? isAuthorisedRequest,
    bool? validate,
    Map<String, dynamic> queryParams = const {},
    List<HttpHeader> headers = const [],
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

    if (params.isAuthorisedRequest) {
      try {
        final tokens = await _tokenManager!.getTokens();

        return await _createRequest(params, tokens);
      } catch (error) {
        if (error is DioError &&
            (delegate?.isAccessTokenExpired(error) ?? false)) {
          final refreshedTokens = await _tokenManager!
              .refreshTokens()
              .catchError((refreshError, st) {
            // ignore: deprecated_member_use_from_same_package
            delegate?.onTokensRefreshingFailed();

            return Error.throwWithStackTrace(refreshError, st);
          });

          return _createRequest(params, refreshedTokens);
        }

        if (error is DioError &&
            (errorHandlerDelegate?.canHandleError(error) ?? false)) {
          errorHandlerDelegate!.handleError(error);
        }

        rethrow;
      }
    }

    return _createRequest(params, null);
  }

  Map<String, String> _headers(List<HttpHeader> headers) =>
      headers.fold({}, (prev, curr) {
        prev[curr.name] = curr.value;

        return prev;
      });

  // ignore: long-method
  Future<T> _createRequest<T>(
    RequestParams params,
    TokenPair? tokenPair,
  ) async {
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
      ) as T;
    } catch (error, stackTrace) {
      if (error is DioError) {
        final response = error.response;
        final type = error.type;

        if (params.isAuthorisedRequest &&
            ((delegate?.isAccessTokenExpired(error) ?? false) ||
                (errorHandlerDelegate?.canHandleError(error) ?? false))) {
          rethrow;
        } else if (!params.validate && response != null) {
          return Future.value(await params.responseMapper(response));
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

  Future<FutureOr<T>> _createDioRequest<T>(
    RequestParams params,
    Options options,
  ) {
    return _isolateManager.sendTask(
      params: params,
      options: options,
      dioMethod: params.method.convertToDio(dio),
    );
  }

  bool _isNetworkConnectionError(DioErrorType type, DioError error) {
    return type == DioErrorType.unknown &&
        error.error != null &&
        error.error is SocketException;
  }

  bool _isTimeoutConnectionError(DioErrorType type, DioError error) {
    return type == DioErrorType.connectionTimeout ||
        type == DioErrorType.receiveTimeout ||
        type == DioErrorType.sendTimeout;
  }

  Map<String, dynamic> _filterNullParams(Map<String, dynamic> queryParams) {
    if (queryParams.isNotEmpty) {
      queryParams.removeWhere((key, value) => value == null);
    }

    return queryParams;
  }
}

enum HttpMethod { get, post, put, patch, delete }

extension HttpMethodExtension on HttpMethod {
  Future<Response<T>> Function(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) convertToDio<T>(Dio dio) {
    switch (this) {
      case HttpMethod.get:
        return dio.get;
      case HttpMethod.post:
        return dio.post;
      case HttpMethod.put:
        return dio.put;
      case HttpMethod.patch:
        return dio.patch;
      case HttpMethod.delete:
        return dio.delete;
    }
  }
}
