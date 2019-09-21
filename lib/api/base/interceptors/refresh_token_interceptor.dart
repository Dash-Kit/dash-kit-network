import 'dart:async';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

abstract class RefreshTokenInterceptorDelegate {
  Future<bool> isAuthorised();

  Future<String> getAuthorisationToken();

  Future<void> updateAuthorisationToken(Dio dio);

  void onRefreshTokenRequestFailed(dynamic error);

  RequestOptions appendAuthorisationTokenToRequest(
    RequestOptions options,
    String authorisationToken,
  ) {
    options.headers['Authorization'] = 'Bearer $authorisationToken';
    return options;
  }

  bool isAccessTokenExpired(DioError error) {
    return error.response?.statusCode == 401;
  }

  Future<bool> isSameToken(Map<String, dynamic> headers) async {
    final requestHeader = headers['Authorization'];
    final currentToken = await getAuthorisationToken();
    final currentHeader = 'Bearer $currentToken';

    return requestHeader == currentHeader;
  }
}

class RefreshTokenInterceptor extends Interceptor {
  static const int MAX_RETRY_COUNT = 2;

  final Dio apiDio;
  final Dio tokenDio;
  final RefreshTokenInterceptorDelegate delegate;

  RefreshTokenInterceptor({
    @required this.apiDio,
    @required this.tokenDio,
    @required this.delegate,
  });

  @override
  onRequest(RequestOptions options) async {
    final authorized = await delegate.isAuthorised();
    final authToken = await delegate.getAuthorisationToken();

    if (authorized && options.extra[AUTHORISED_REQUEST] == true) {
      delegate.appendAuthorisationTokenToRequest(options, authToken);
    }

    return options;
  }

  @override
  onError(DioError error) async {
    final request = error.request;
    final sameToken = await delegate.isSameToken(request.headers);
    final isTokenRequest = request.path.contains('auth_tokens');

    if (delegate.isAccessTokenExpired(error) &&
        request.extra[AUTHORISED_REQUEST] && !isTokenRequest) {
      _lockApi();

      return await (sameToken ? _refreshToken(error) : Future.value(null))
          .then((response) async {
        _unlockApi();

        if (response is DioError) {
          return response;
        }

        final authToken = await delegate.getAuthorisationToken();
        delegate.appendAuthorisationTokenToRequest(request, authToken);

        return apiDio.request(request.path, options: request);
      });
    } else {
      return error;
    }
  }

  Future<dynamic> _refreshToken(DioError error) {
    return delegate.getAuthorisationToken().then((token) {
      if (token?.isNotEmpty == true) {
        return delegate.updateAuthorisationToken(tokenDio).catchError((e, s) {
          delegate.onRefreshTokenRequestFailed(e);
          return error;
        });
      } else {
        return Future.value(error);
      }
    });
  }

  void _lockApi() {
    apiDio.interceptors.requestLock.lock();
    apiDio.interceptors.responseLock.lock();
    apiDio.interceptors.errorLock.lock();
  }

  void _unlockApi() {
    apiDio.interceptors.requestLock.unlock();
    apiDio.interceptors.responseLock.unlock();
    apiDio.interceptors.errorLock.unlock();
  }
}

const AUTHORISED_REQUEST = 'AUTHORISED_REQUEST';
