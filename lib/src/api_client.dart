import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dash_kit_network/src/exceptions/network_connection_exception.dart';
import 'package:dash_kit_network/src/exceptions/refresh_tokens_delegate_missing_exception.dart';
import 'package:dash_kit_network/src/exceptions/request_error_exception.dart';
import 'package:dash_kit_network/src/models/api_environment.dart';
import 'package:dash_kit_network/src/models/http_header.dart';
import 'package:dash_kit_network/src/models/request_params.dart';
import 'package:dash_kit_network/src/models/response_mapper.dart';
import 'package:dash_kit_network/src/models/token_pair.dart';
import 'package:dash_kit_network/src/refresh_tokens_delegate.dart';
import 'package:dash_kit_network/src/token_manager_provider.dart';
import 'package:dash_kit_network/src/error_handler_delegate.dart';
import 'package:meta/meta.dart';

enum HttpMethod { get, post, put, patch, delete }

/// Componet for communication with an API. Includes functionality
/// for updating tokens if they expired
abstract class ApiClient {
  ApiClient({
    @required this.environment,
    @required this.dio,
    this.commonHeaders = const [],
    this.delegate,
    this.errorHandlerDelegate,
  }) : _provider = TokenManagerProvider(delegate, dio) {
    dio.options.baseUrl = environment.baseUrl;
  }

  final ApiEnvironment environment;
  final Dio dio;
  final List<HttpHeader> commonHeaders;
  final RefreshTokensDelegate delegate;
  final ErrorHandlerDelegate errorHandlerDelegate;
  final TokenManagerProvider _provider;

  Future<T> get<T>({
    @required String path,
    Map<String, dynamic> queryParams,
    List<HttpHeader> headers = const [],
    ResponseMapper<T> responseMapper,
    bool isAuthorisedRequest,
    bool validate,
    int connectTimeout,
    int receiveTimeout,
    int sendTimeout,
    String contentType = Headers.jsonContentType,
  }) {
    return _request(RequestParams<T>(
      method: HttpMethod.get,
      path: path,
      headers: headers,
      queryParams: _filterNullParams(queryParams ?? {}),
      responseMapper: responseMapper,
      validate: validate ?? environment.validateRequestsByDefaut,
      isAuthorisedRequest:
          isAuthorisedRequest ?? environment.isRequestsAuthorisedByDefault,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      contentType: contentType,
    ));
  }

  Future<T> post<T>({
    @required String path,
    List<HttpHeader> headers = const [],
    ResponseMapper<T> responseMapper,
    dynamic body,
    bool isAuthorisedRequest,
    bool validate,
    ResponseType responseType = ResponseType.json,
    int connectTimeout,
    int receiveTimeout,
    int sendTimeout,
    String contentType = Headers.jsonContentType,
  }) {
    return _request(RequestParams<T>(
      method: HttpMethod.post,
      path: path,
      headers: headers,
      responseMapper: responseMapper,
      body: body,
      responseType: responseType,
      validate: validate ?? environment.validateRequestsByDefaut,
      isAuthorisedRequest:
          isAuthorisedRequest ?? environment.isRequestsAuthorisedByDefault,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      contentType: contentType,
    ));
  }

  Future<T> put<T>({
    @required String path,
    List<HttpHeader> headers = const [],
    ResponseMapper<T> responseMapper,
    dynamic body,
    bool isAuthorisedRequest,
    bool validate,
    ResponseType responseType = ResponseType.json,
    int connectTimeout,
    int receiveTimeout,
    int sendTimeout,
    String contentType = Headers.jsonContentType,
  }) {
    return _request(RequestParams<T>(
      method: HttpMethod.put,
      path: path,
      headers: headers,
      responseMapper: responseMapper,
      body: body,
      responseType: responseType,
      validate: validate ?? environment.validateRequestsByDefaut,
      isAuthorisedRequest:
          isAuthorisedRequest ?? environment.isRequestsAuthorisedByDefault,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      contentType: contentType,
    ));
  }

  Future<T> patch<T>({
    @required String path,
    List<HttpHeader> headers = const [],
    ResponseMapper<T> responseMapper,
    dynamic body,
    bool isAuthorisedRequest,
    bool validate,
    ResponseType responseType = ResponseType.json,
    int connectTimeout,
    int receiveTimeout,
    int sendTimeout,
    String contentType = Headers.jsonContentType,
  }) {
    return _request(RequestParams<T>(
      method: HttpMethod.patch,
      path: path,
      headers: headers,
      responseMapper: responseMapper,
      body: body,
      responseType: responseType,
      validate: validate ?? environment.validateRequestsByDefaut,
      isAuthorisedRequest:
          isAuthorisedRequest ?? environment.isRequestsAuthorisedByDefault,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      contentType: contentType,
    ));
  }

  Future<T> delete<T>({
    @required String path,
    List<HttpHeader> headers = const [],
    ResponseMapper<T> responseMapper,
    dynamic body,
    bool isAuthorisedRequest,
    bool validate,
    int connectTimeout,
    int receiveTimeout,
    int sendTimeout,
    String contentType = Headers.jsonContentType,
  }) {
    return _request(RequestParams<T>(
      method: HttpMethod.delete,
      path: path,
      responseMapper: responseMapper,
      body: body,
      headers: headers,
      validate: validate ?? environment.validateRequestsByDefaut,
      isAuthorisedRequest:
          isAuthorisedRequest ?? environment.isRequestsAuthorisedByDefault,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      contentType: contentType,
    ));
  }

  Future<void> updateAuthTokens(TokenPair tokenPair) async {
    final tokenManager = await _provider.getTokenManager();

    tokenManager.updateTokens(tokenPair);
    await delegate?.onTokensUpdated(tokenPair);
  }

  Future<void> clearAuthTokens() {
    const emptyTokenPair = TokenPair(
      accessToken: '',
      refreshToken: '',
    );

    return updateAuthTokens(emptyTokenPair);
  }

  Future<bool> isAuthorised() async {
    if (delegate == null) {
      return false;
    }

    final tokenPair = await delegate.loadTokensFromStorage();
    return tokenPair?.accessToken?.isNotEmpty == true;
  }

  Future<T> _request<T>(RequestParams params) async {
    if (params.isAuthorisedRequest && delegate == null) {
      throw RefreshTokensDelegateMissingException();
    }

    final Future<T> Function(TokenPair) performRequest = (tokenPair) async {
      final response = await _createRequest(params, tokenPair);
      return params.responseMapper?.call(response) ?? response?.data;
    };

    if (params.isAuthorisedRequest) {
      try {
        final tokenManager = await _provider.getTokenManager();
        final tokens = await tokenManager.getTokens();
        return await performRequest(tokens);
      } catch (error) {
        if (error is DioError && delegate.isAccessTokenExpired(error)) {
          final tokenManager = await _provider.getTokenManager();

          final refreshedTokens =
              await tokenManager.refreshTokens().catchError((refreshError) {
            if (refreshError is DioError &&
                delegate.isRefreshTokenExpired(refreshError)) {
              delegate.onTokensRefreshingFailed();
            }

            throw refreshError;
          });

          return await performRequest(refreshedTokens);
        }

        if (error is DioError &&
            (errorHandlerDelegate?.canHandleError(error) ?? false)) {
          errorHandlerDelegate.handleError(error);
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

  Future<Response> _createRequest(
    RequestParams params,
    TokenPair tokenPair,
  ) async {
    final cancelToken = CancelToken();
    var options = Options(
      headers: _headers([...params.headers, ...commonHeaders]),
      responseType: params.responseType,
      receiveTimeout: params.receiveTimeout,
      sendTimeout: params.sendTimeout,
      contentType: params.contentType,
    );

    if (params.isAuthorisedRequest) {
      options = delegate.appendAccessTokenToRequest(
        options,
        tokenPair,
      );
    }

    try {
      final result = await _createDioRequest(
        params,
        options,
        cancelToken,
      );
      return result;
    } catch (error) {
      if (error is DioError) {
        final response = error.response;
        final type = error.type;

        if (params.isAuthorisedRequest &&
            (delegate.isAccessTokenExpired(error) ||
                delegate.isRefreshTokenExpired(error) ||
                (errorHandlerDelegate?.canHandleError(error) ?? false))) {
          rethrow;
        } else if (!params.validate && response != null) {
          return Future.value(error.response);
        } else if (_isNetworkConnectionError(type, error)) {
          throw NetworkConnectionException(error);
        } else {
          throw RequestErrorException(error);
        }
      }

      rethrow;
    }
  }

  Future<Response> _createDioRequest(
    RequestParams params,
      Options options,
    CancelToken cancelToken,
  ) {
    switch (params.method) {
      case HttpMethod.get:
        return dio.get(
          params.path,
          queryParameters: params.queryParams,
          options: options,
          cancelToken: cancelToken,
        );
        break;

      case HttpMethod.post:
        return dio.post(
          params.path,
          data: params.body,
          options: options,
          cancelToken: cancelToken,
        );
        break;

      case HttpMethod.put:
        return dio.put(
          params.path,
          data: params.body,
          options: options,
          cancelToken: cancelToken,
        );
        break;

      case HttpMethod.patch:
        return dio.patch(
          params.path,
          data: params.body,
          options: options,
          cancelToken: cancelToken,
        );
        break;

      case HttpMethod.delete:
        return dio.delete(
          params.path,
          data: params.body,
          options: options,
          cancelToken: cancelToken,
        );
        break;
    }

    assert(false, 'HTTP request method is required');
    return null;
  }

  bool _isNetworkConnectionError(DioErrorType type, DioError error) {
    return type == DioErrorType.connectTimeout ||
        type == DioErrorType.receiveTimeout ||
        type == DioErrorType.sendTimeout ||
        error?.error is SocketException;
  }

  Map<String, dynamic> _filterNullParams(Map<String, dynamic> queryParams) {
    if (queryParams.isNotEmpty) {
      queryParams.removeWhere((key, value) => value == null);
    }

    return queryParams;
  }
}
