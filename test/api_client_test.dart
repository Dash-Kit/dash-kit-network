import 'package:flutter_platform_network/flutter_platform_network.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'api_client_test_utils.dart';
import 'mocks/mock_dio.dart';
import 'mocks/mock_token_storage.dart';
import 'test_components/test_api_client.dart';
import 'test_components/test_refresh_tokens_delegate.dart';

void main() {
  Dio dio;
  BaseOptions dioBaseOptions;
  TestApiClient apiClient;
  TestRefreshTokensDelegate delegate;
  TokenStorage tokenStorage;

  setUp(() {
    dio = MockDio();
    dioBaseOptions = BaseOptions();

    tokenStorage = MockTokenStorage();
    delegate = TestRefreshTokensDelegate(tokenStorage);
  });

  test('Successful request execution', () async {
    stubAccessToken(tokenStorage, '<access_token>');
    stubRefreshToken(tokenStorage, '<refresh_token>');
    stubDioOptions(dio, dioBaseOptions);

    apiClient = TestApiClient(dio, delegate);

    onUserRequestAnswer(dio, () {
      return Future.value(Response(statusCode: 200, data: ['John', 'Mary']));
    });

    await Future.delayed(Duration(milliseconds: 200));

    final usersRequest = apiClient.get(
      path: 'users',
      isAuthorisedRequest: true,
    );

    final users = await usersRequest.first;

    expect(users, ['John', 'Mary']);

    verifyInOrder([
      dio.options,
      userRequest(dio, accessToken: '<access_token>'),
    ]);

    verify(tokenStorage.getAccessToken()).called(1);
    verify(tokenStorage.getRefreshToken()).called(1);

    verifyNoMoreInteractions(tokenStorage);
    verifyNoMoreInteractions(dio);
  });

  test('Failed request does not trigger token refreshing', () async {
    stubAccessToken(tokenStorage, '<access_token>');
    stubRefreshToken(tokenStorage, '<refresh_token>');
    stubDioOptions(dio, dioBaseOptions);

    apiClient = TestApiClient(dio, delegate);

    onUserRequestAnswer(dio, () {
      return Future.error(Response(statusCode: 403));
    });

    await Future.delayed(Duration(milliseconds: 200));

    final usersRequest = apiClient.get(
      path: 'users',
      isAuthorisedRequest: true,
    );

    bool isRequestFailed = false;
    try {
      await usersRequest.first;
    } catch (e) {
      isRequestFailed = true;
    }

    expect(isRequestFailed, true, reason: 'Request should failed');

    verifyInOrder([
      dio.options,
      userRequest(dio, accessToken: '<access_token>'),
    ]);

    verify(tokenStorage.getAccessToken()).called(1);
    verify(tokenStorage.getRefreshToken()).called(1);

    verifyNoMoreInteractions(tokenStorage);
    verifyNoMoreInteractions(dio);
  });

  test('Tokens refreshing successfully', () async {
    stubAccessToken(tokenStorage, '<access_token>');
    stubRefreshToken(tokenStorage, '<refresh_token>');
    stubDioOptions(dio, dioBaseOptions);

    apiClient = TestApiClient(dio, delegate);

    var counter = 0;
    onUserRequestAnswer(dio, () {
      if (counter < 1) {
        counter++;
        return Future.error(DioError(response: Response(statusCode: 401)));
      }

      return Future.value(Response(statusCode: 200, data: ['John', 'Mary']));
    });

    onRefreshRequestAnswer(dio, () {
      return Future.value(Response(statusCode: 200, data: {
        'access_token': '<refreshed_access_token>',
        'refresh_token': '<refreshed_refresh_token>',
      }));
    });

    await Future.delayed(Duration(milliseconds: 200));

    final usersRequest = apiClient.get(
      path: 'users',
      isAuthorisedRequest: true,
    );

    final users = await usersRequest.first;

    expect(users, ['John', 'Mary']);

    verifyInOrder([
      dio.options,
      userRequest(dio, accessToken: '<access_token>'),
      refreshTokensRequest(dio),
      userRequest(dio, accessToken: '<refreshed_access_token>'),
    ]);

    verify(tokenStorage.getAccessToken()).called(1);
    verify(tokenStorage.getRefreshToken()).called(1);

    verify(tokenStorage.saveTokens(
      accessToken: '<refreshed_access_token>',
      refreshToken: '<refreshed_refresh_token>',
    )).called(1);

    verifyNoMoreInteractions(tokenStorage);
    verifyNoMoreInteractions(dio);
  });

  test('Tokens refreshing failed', () async {
    stubAccessToken(tokenStorage, '<access_token>');
    stubRefreshToken(tokenStorage, '<refresh_token>');
    stubDioOptions(dio, dioBaseOptions);

    bool isRefreshingFailed = false;
    delegate = TestRefreshTokensDelegate(
      tokenStorage,
      onTokenRefreshingFailedCallback: () => isRefreshingFailed = true,
    );

    apiClient = TestApiClient(dio, delegate);

    onUserRequestAnswer(dio, () {
      return Future.error(DioError(response: Response(statusCode: 401)));
    });

    when(dio.post('refresh_tokens')).thenAnswer(
      (_) => Future.error(DioError(response: Response(statusCode: 401))),
    );

    await Future.delayed(Duration(milliseconds: 200));

    final usersRequest = apiClient.get(
      path: 'users',
      isAuthorisedRequest: true,
    );

    try {
      await usersRequest.first;
    } catch (error) {
      expect(error, isNotNull);
    }

    expect(
      isRefreshingFailed,
      true,
      reason: 'Refresh tokens failed callback must be called',
    );

    verifyInOrder([
      dio.options,
      userRequest(dio, accessToken: '<access_token>'),
      refreshTokensRequest(dio),
      refreshTokensRequest(dio),
      refreshTokensRequest(dio),
    ]);

    verify(tokenStorage.getAccessToken()).called(1);
    verify(tokenStorage.getRefreshToken()).called(1);

    verifyNoMoreInteractions(tokenStorage);
    verifyNoMoreInteractions(dio);
  });
}
