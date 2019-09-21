import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_network/api/base/token_manager.dart';
import 'package:flutter_platform_network/api/base/interceptors/refresh_token_interceptor.dart';

class MockRefreshTokenInterceptorDelegate
    extends RefreshTokenInterceptorDelegate {
  final TokenManager tokenManager;
  final Dio apiDio;
  final Dio tokenDio;

  MockRefreshTokenInterceptorDelegate({
    @required this.apiDio,
    @required this.tokenDio,
    @required this.tokenManager,
  });

  noSuchMethod(Invocation invocation) => null;

  @override
  Future<bool> isAuthorised() {
    return tokenManager.authorized();
  }
}
