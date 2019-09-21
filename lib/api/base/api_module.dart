import 'package:dio/dio.dart';
import 'package:flutter_platform_network/api/base/api.dart';
import 'package:flutter_platform_network/api/base/api_environment.dart';
import 'package:flutter_platform_network/api/base/interceptors/refresh_token_interceptor.dart';
import 'package:flutter_platform_network/debug/debug.dart';

class ApiModule<T extends API> {
  T api;

  ApiModule({
    final Dio apiDio,
    final Dio tokenDio,
    final APIEnvironment apiEnvironment,
    final RefreshTokenInterceptorDelegate refreshTokenDelegate,
    final List<Interceptor> interceptors = const [],
    final T Function(APIEnvironment, Dio) apiCreator,
  }) {
    final refreshTokenInterceptor = RefreshTokenInterceptor(
      apiDio: apiDio,
      tokenDio: tokenDio,
      delegate: refreshTokenDelegate,
    );

    apiDio.options.baseUrl = apiEnvironment.baseUrl;
    apiDio.interceptors.add(refreshTokenInterceptor);

    apiDio.options.connectTimeout = 30 * 1000;
    apiDio.options.receiveTimeout = 60 * 1000;
    apiDio.options.sendTimeout = 60 * 1000;

    tokenDio.options.baseUrl = apiEnvironment.baseUrl;

    debug(() {
      apiDio.interceptors.addAll(interceptors);

      apiDio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
      tokenDio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    });

    api = apiCreator(apiEnvironment, apiDio);
  }
}