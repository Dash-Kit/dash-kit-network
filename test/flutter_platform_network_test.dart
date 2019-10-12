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
  Dio apiDio;
  Dio tokenDio;

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

    when(delegate.getAuthorisationToken())
        .thenAnswer((_) => Future.value('token'));
    when(delegate.updateAuthorisationToken(tokenDio))
        .thenAnswer((_) => Future.sync(() {}));
  });

  test('Check success refreshing token', () async {
    error = DioError(
        request: RequestOptions(
      path: "/",
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

    verify(delegate.isSameToken(error.request.headers)).called(1);
    verify(delegate.isAccessTokenExpired(error)).called(1);

    verify(apiDio.interceptors.requestLock.lock()).called(1);
    verify(apiDio.interceptors.responseLock.lock()).called(1);
    verify(apiDio.interceptors.errorLock.lock()).called(1);

    verify(delegate.getAuthorisationToken()).called(2);
    verify(delegate.updateAuthorisationToken(tokenDio)).called(1);
    verify(apiDio.request(error.request.path, options: error.request))
        .called(1);
    verify(delegate.appendAuthorisationTokenToRequest(error.request, any))
        .called(1);

    verify(apiDio.interceptors.requestLock.unlock()).called(1);
    verify(apiDio.interceptors.responseLock.unlock()).called(1);
    verify(apiDio.interceptors.errorLock.unlock()).called(1);

    verifyNoMoreInteractions(delegate);
    verifyNoMoreInteractions(apiDio);
    verifyNoMoreInteractions(tokenDio);

    expect(response, isNot(isA<DioError>()));
  });

  test('Check fail refreshing token', () async {
    error = DioError(
        request: RequestOptions(
      path: "/",
      extra: {AUTHORISED_REQUEST: true},
    ));

    when(delegate.isAuthorised()).thenAnswer((_) => Future.value(true));
    when(delegate.isSameToken(error.request.headers))
        .thenAnswer((_) => Future.value(true));
    when(delegate.isAccessTokenExpired(error)).thenReturn(true);
    when(delegate.getAuthorisationToken())
        .thenAnswer((_) => Future.value(''));

    final response = await interceptor.onError(error);

    verify(delegate.isSameToken(error.request.headers)).called(1);
    verify(delegate.isAccessTokenExpired(error)).called(1);

    verify(apiDio.interceptors.requestLock.lock()).called(1);
    verify(apiDio.interceptors.responseLock.lock()).called(1);
    verify(apiDio.interceptors.errorLock.lock()).called(1);

    verify(delegate.getAuthorisationToken()).called(1);

    verify(apiDio.interceptors.requestLock.unlock()).called(1);
    verify(apiDio.interceptors.responseLock.unlock()).called(1);
    verify(apiDio.interceptors.errorLock.unlock()).called(1);

    verifyNoMoreInteractions(delegate);
    verifyNoMoreInteractions(apiDio);
    verifyNoMoreInteractions(tokenDio);

    expect(response, isA<DioError>());
  });

  test('Check auth token not expired', () async {
    error = DioError(
        request: RequestOptions(
      path: "/",
      extra: {AUTHORISED_REQUEST: true},
    ));

    when(delegate.isAuthorised()).thenAnswer((_) => Future.value(true));
    when(delegate.isSameToken(error.request.headers))
        .thenAnswer((_) => Future.value(true));
    when(delegate.isAccessTokenExpired(error)).thenReturn(false);

    final response = await interceptor.onError(error);

    verify(delegate.isSameToken(error.request.headers)).called(1);
    verify(delegate.isAccessTokenExpired(error)).called(1);

    verifyNoMoreInteractions(delegate);
    verifyNoMoreInteractions(apiDio);
    verifyNoMoreInteractions(tokenDio);

    expect(response, isA<DioError>());
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

class MockApiDio extends Mock implements DioMixin {
  final interceptors = MockInterceptors();
}

class MockTokenManager extends Mock implements TokenManager {}

class MockInterceptors extends Mock implements Interceptors {
  Lock requestLock = MockLock();
  Lock responseLock = MockLock();
  Lock errorLock = MockLock();
}

class MockLock extends Mock implements Lock {}
