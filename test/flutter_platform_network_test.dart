import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_network/api/base/interceptors/refresh_token_interceptor.dart';
import 'package:flutter_platform_network/api/base/token_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  DioError error;
  RefreshTokenInterceptor interceptor;
  MockRefreshTokenInterceptorDelegate delegate;
  MockApiDio apiDio;
  MockApiDio tokenDio;

  setUp(() async {
    apiDio = MockApiDio();
    tokenDio = MockApiDio();

    delegate = MockRefreshTokenInterceptorDelegate(
      apiDio: apiDio,
      tokenDio: tokenDio,
      tokenManager: MockTokenManager(),
    );
    interceptor = RefreshTokenInterceptor(
      apiDio: apiDio,
      tokenDio: tokenDio,
      delegate: delegate,
    );

    when(apiDio.interceptors).thenReturn(Interceptors());
  });

  test('Check success refreshing token', () async {
    error = DioError(
        request: RequestOptions(
      path: "",
      extra: {AUTHORISED_REQUEST: true},
    ));

    when(delegate.isAuthorised()).thenAnswer((_) => Future.value(true));
    when(delegate.isSameToken(error.request.headers))
        .thenAnswer((_) => Future.value(true));
    when(delegate.isAccessTokenExpired(error)).thenReturn(true);
    when(delegate.getAuthorisationToken())
        .thenAnswer((_) => Future.value('token'));
    when(delegate.updateAuthorisationToken(tokenDio))
        .thenAnswer((_) => Future.value());

    final response = await interceptor.onError(error);

    verify(delegate.isAccessTokenExpired(error)).called(1);
//    verify(interceptor.refreshToken(error)).called(1);
    expect(response, isNot(isA<DioError>()));
  });
}

class MockRefreshTokenInterceptorDelegate extends Mock
    implements RefreshTokenInterceptorDelegate {
  final TokenManager tokenManager;
  final Dio apiDio;
  final Dio tokenDio;

  MockRefreshTokenInterceptorDelegate({
    @required this.apiDio,
    @required this.tokenDio,
    @required this.tokenManager,
  });
}

class MockApiDio extends Mock implements DioMixin {}

class MockTokenManager extends Mock implements TokenManager {}
