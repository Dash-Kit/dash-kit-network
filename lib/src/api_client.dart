import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_platform_network/src/exceptions/network_connection_exception.dart';
import 'package:flutter_platform_network/src/exceptions/refresh_tokens_delegate_missing_exception.dart';
import 'package:flutter_platform_network/src/exceptions/request_error_exception.dart';
import 'package:flutter_platform_network/src/models/api_environment.dart';
import 'package:flutter_platform_network/src/models/http_header.dart';
import 'package:flutter_platform_network/src/models/request_params.dart';
import 'package:flutter_platform_network/src/models/response_mapper.dart';
import 'package:flutter_platform_network/src/models/token_pair.dart';
import 'package:flutter_platform_network/src/refresh_tokens_delegate.dart';
import 'package:flutter_platform_network/src/token_manager_provider.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

enum HttpMethod { get, post, put, patch, delete }

/// Componet for communication with an API. Includes functionality
/// for updating tokens if they expired
abstract class ApiClient {
  ApiClient({
    @required this.environment,
    @required this.dio,
    this.delegate,
  }) : _provider = TokenManagerProvider(delegate, dio) {
    dio.options.baseUrl = environment.baseUrl;
  }

  final ApiEnvironment environment;
  final Dio dio;
  final RefreshTokensDelegate delegate;
  final TokenManagerProvider _provider;

  Observable<T> get<T>({
    @required String path,
    Map<String, dynamic> queryParams,
    List<HttpHeader> headers = const [],
    ResponseMapper<T> responseMapper,
    bool isAuthorisedRequest,
    bool validate,
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
    ));
  }

  Observable<T> post<T>({
    @required String path,
    List<HttpHeader> headers = const [],
    ResponseMapper<T> responseMapper,
    dynamic body,
    bool isAuthorisedRequest,
    bool validate,
    ResponseType responseType = ResponseType.json,
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
    ));
  }

  Observable<T> put<T>({
    @required String path,
    List<HttpHeader> headers = const [],
    ResponseMapper<T> responseMapper,
    dynamic body,
    bool isAuthorisedRequest,
    bool validate,
    ResponseType responseType = ResponseType.json,
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
    ));
  }

  Observable<T> patch<T>({
    @required String path,
    List<HttpHeader> headers = const [],
    ResponseMapper<T> responseMapper,
    dynamic body,
    bool isAuthorisedRequest,
    bool validate,
    ResponseType responseType = ResponseType.json,
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
    ));
  }

  Observable<T> delete<T>({
    @required String path,
    List<HttpHeader> headers = const [],
    ResponseMapper<T> responseMapper,
    dynamic body,
    bool isAuthorisedRequest,
    bool validate,
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
    ));
  }

  void updateAuthTokens(TokenPair tokenPair) {
    _provider.getTokenManager().listen((tokenManager) {
      tokenManager.updateTokens(tokenPair);
      delegate?.onTokensUpdated(tokenPair);
    });
  }

  void clearAuthTokens() {
    const emptyTokenPair = TokenPair(
      accessToken: '',
      refreshToken: '',
    );

    _provider.getTokenManager().listen((tokenManager) {
      tokenManager.updateTokens(emptyTokenPair);
      delegate?.onTokensUpdated(emptyTokenPair);
    });
  }

  Future<bool> isAuthorised() async {
    if (delegate == null) {
      return false;
    }

    final tokenPair = await delegate.loadTokensFromStorage();
    return tokenPair?.accessToken?.isNotEmpty == true;
  }

  Observable<T> _request<T>(RequestParams params) {
    if (params.isAuthorisedRequest && delegate == null) {
      throw RefreshTokensDelegateMissingException();
    }

    final Observable<T> Function(TokenPair) performRequest = (tokenPair) =>
        _createRequest(params, tokenPair)
            .map(params.responseMapper ?? (response) => response?.data);

    if (params.isAuthorisedRequest) {
      final Stream<T> Function(dynamic) processAccessTokenError = (error) {
        if (error is DioError && delegate.isAccessTokenExpired(error)) {
          return _provider
              .getTokenManager()
              .flatMap((tokenManager) => tokenManager.refreshTokens())
              .flatMap(performRequest);
        }

        return Observable.error(error);
      };

      final Stream<T> Function(dynamic) processRefreshTokenError = (error) {
        if (error is DioError && delegate.isRefreshTokenExpired(error)) {
          delegate.onTokensRefreshingFailed();
        }

        return Observable.error(error);
      };

      return _provider
          .getTokenManager()
          .flatMap((tokenManager) => tokenManager.getTokens())
          .flatMap(performRequest)
          .onErrorResume(processAccessTokenError)
          .onErrorResume(processRefreshTokenError);
    }

    return performRequest(null);
  }

  Map<String, String> _headers(List<HttpHeader> headers) =>
      headers.fold({}, (prev, curr) {
        prev[curr.name] = curr.value;
        return prev;
      });

  Observable<Response> _createRequest(
    RequestParams params,
    TokenPair tokenPair,
  ) {
    StreamController<Response> controller;

    final cancelToken = CancelToken();
    var options = RequestOptions(
      headers: _headers(params.headers),
      responseType: params.responseType,
    );

    if (params.isAuthorisedRequest) {
      options = delegate.appendAccessTokenToRequest(
        options,
        tokenPair,
      );
    }

    final onListen = () {
      final Future<Response> request = _createDioRequest(
        params,
        options,
        cancelToken,
      );

      final onData = (Response response) {
        controller.add(response);
        controller.close();
      };

      final onError = (error) {
        if (error is DioError) {
          final response = error.response;
          final type = error.type;

          if (params.isAuthorisedRequest &&
              (delegate.isAccessTokenExpired(error) ||
                  delegate.isRefreshTokenExpired(error))) {
            controller.addError(error);
          } else if (!params.validate && response != null) {
            controller.add(error.response);
          } else if (_isNetworkConnectionError(type, error)) {
            controller.addError(NetworkConnectionException(error));
          } else {
            controller.addError(RequestErrorException(error));
          }

          controller.close();
          return;
        }

        controller.addError(error);
        controller.close();
      };

      request.then(onData).catchError(onError);
    };

    final onCancel = () => cancelToken.cancel();

    controller = StreamController<Response>.broadcast(
      onListen: onListen,
      onCancel: onCancel,
    );

    return Observable(controller.stream);
  }

  Future<Response> _createDioRequest(
    RequestParams params,
    RequestOptions options,
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
    return type == DioErrorType.CONNECT_TIMEOUT ||
        type == DioErrorType.RECEIVE_TIMEOUT ||
        type == DioErrorType.SEND_TIMEOUT ||
        error?.error is SocketException;
  }

  Map<String, dynamic> _filterNullParams(Map<String, dynamic> queryParams) {
    if (queryParams.isNotEmpty) {
      queryParams.removeWhere((key, value) => value == null);
    }

    return queryParams;
  }
}
