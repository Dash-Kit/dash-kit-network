import 'dart:io';

import 'package:dash_kit_network/dash_kit_network.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'api_client_test.mocks.dart';
import 'api_client_test_utils.dart';
import 'test_components/test_api_client.dart';
import 'test_components/test_refresh_tokens_delegate.dart';

@GenerateNiceMocks([MockSpec<TokenStorage>(), MockSpec<Dio>()])
void main() {
  late Dio dio;
  late BaseOptions dioBaseOptions;
  late TestApiClient apiClient;
  late TestRefreshTokensDelegate delegate;
  late TokenStorage tokenStorage;

  setUp(() {
    dio = MockDio();
    dioBaseOptions = BaseOptions();

    tokenStorage = MockTokenStorage();
    delegate = TestRefreshTokensDelegate(tokenStorage);
  });

  test('No tokens exists', () async {
    stubAccessToken(tokenStorage, '');
    stubRefreshToken(tokenStorage, '');
    stubDioOptions(dio, dioBaseOptions);

    apiClient = TestApiClient(dio, delegate);

    onUserRequestAnswer(dio, () {
      return Future.error(DioException(
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(),
        ),
        requestOptions: RequestOptions(),
      ));
    });

    onRefreshRequestAnswer(dio, () {
      return Future.error(DioException(
        response: Response(
          statusCode: 400,
          requestOptions: RequestOptions(),
        ),
        requestOptions: RequestOptions(),
      ));
    });

    final usersRequest = apiClient.get(
      path: 'users',
      body: {},
      isAuthorisedRequest: true,
      responseMapper: (response) => response,
    );

    var isRequestFailed = false;
    try {
      await usersRequest;
    } catch (e) {
      isRequestFailed = true;
    }

    expect(isRequestFailed, true, reason: 'Request should failed');

    verifyInOrder([
      dio.options,
      userRequest(dio),
      refreshTokensRequest(dio),
    ]);

    verify(tokenStorage.getAccessToken()).called(2);
    verify(tokenStorage.getRefreshToken()).called(2);

    verifyNoMoreInteractions(tokenStorage);
    verifyNoMoreInteractions(dio);
  });

  test('Successful request execution', () async {
    stubAccessToken(tokenStorage, '<access_token>');
    stubRefreshToken(tokenStorage, '<refresh_token>');
    stubDioOptions(dio, dioBaseOptions);

    apiClient = TestApiClient(dio, delegate);

    onUserRequestAnswer(dio, () {
      return Future.value(Response(
        statusCode: 200,
        data: ['John', 'Mary'],
        requestOptions: RequestOptions(),
      ));
    });

    final users = await apiClient.get(
      path: 'users',
      isAuthorisedRequest: true,
      responseMapper: (response) => response,
    );

    expect(users.data, ['John', 'Mary']);

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
      return Future.error(DioException(
        response: Response(
          statusCode: 403,
          requestOptions: RequestOptions(),
        ),
        requestOptions: RequestOptions(),
      ));
    });

    final usersRequest = apiClient.get(
      path: 'users',
      isAuthorisedRequest: true,
      responseMapper: (response) => response,
    );

    var isRequestFailed = false;
    try {
      await usersRequest;
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

        return Future.error(DioException(
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(),
          ),
          requestOptions: RequestOptions(),
        ));
      }

      return Future.value(Response(
        statusCode: 200,
        data: ['John', 'Mary'],
        requestOptions: RequestOptions(),
      ));
    });

    onRefreshRequestAnswer(dio, () {
      return Future.value(Response(
        statusCode: 200,
        data: {
          'access_token': '<refreshed_access_token>',
          'refresh_token': '<refreshed_refresh_token>',
        },
        requestOptions: RequestOptions(),
      ));
    });

    final usersRequest = apiClient.get(
      path: 'users',
      isAuthorisedRequest: true,
      responseMapper: (response) => response,
    );

    final users = await usersRequest;

    expect(users.data, ['John', 'Mary']);

    verifyInOrder([
      dio.options,
      userRequest(dio, accessToken: '<access_token>'),
      refreshTokensRequest(dio),
      userRequest(dio, accessToken: '<refreshed_access_token>'),
    ]);

    verify(tokenStorage.getAccessToken()).called(2);
    verify(tokenStorage.getRefreshToken()).called(2);

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

    var isRefreshingFailed = false;
    delegate = TestRefreshTokensDelegate(
      tokenStorage,
      onTokenRefreshingFailedCallback: () => isRefreshingFailed = true,
    );

    apiClient = TestApiClient(dio, delegate);

    onUserRequestAnswer(dio, () {
      return Future.error(DioException(
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(),
        ),
        requestOptions: RequestOptions(),
      ));
    });

    when(dio.post('refresh_tokens')).thenAnswer(
      (_) => Future.error(DioException(
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(),
        ),
        requestOptions: RequestOptions(),
      )),
    );

    final usersRequest = apiClient.get(
      path: 'users',
      isAuthorisedRequest: true,
      responseMapper: (response) => response,
    );

    try {
      await usersRequest;
    } catch (error) {
      expect(error, isNotNull);
      expect(error, isA<RefreshTokenException>());
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
    ]);

    verify(tokenStorage.getAccessToken()).called(2);
    verify(tokenStorage.getRefreshToken()).called(2);

    verifyNoMoreInteractions(tokenStorage);
    verifyNoMoreInteractions(dio);
  });

  test('Network connection error arrive after dio connectionError', () async {
    stubAccessToken(tokenStorage, '<access_token>');
    stubRefreshToken(tokenStorage, '<refresh_token>');
    stubDioOptions(dio, dioBaseOptions);

    var isRefreshingFailed = false;
    delegate = TestRefreshTokensDelegate(
      tokenStorage,
      onTokenRefreshingFailedCallback: () => isRefreshingFailed = true,
    );

    apiClient = TestApiClient(dio, delegate);

    onUserRequestAnswer(dio, () {
      return Future.error(DioException(
        type: DioExceptionType.connectionError,
        error: const SocketException(''),
        requestOptions: RequestOptions(),
      ));
    });

    when(dio.post('refresh_tokens')).thenAnswer(
      (_) => Future.error(DioException(
        type: DioExceptionType.connectionError,
        error: const SocketException(''),
        requestOptions: RequestOptions(),
      )),
    );

    final usersRequest = apiClient.get(
      path: 'users',
      isAuthorisedRequest: true,
      responseMapper: (response) => response,
    );

    try {
      await usersRequest;
    } catch (error) {
      expect(error, isNotNull);
      expect(error, isA<NetworkConnectionException>());
    }

    expect(
      isRefreshingFailed,
      false,
      reason: 'Refresh tokens failed callback must not be called',
    );

    verifyInOrder([
      dio.options,
      userRequest(dio, accessToken: '<access_token>'),
    ]);

    verifyNever(refreshTokensRequest(dio));

    verify(tokenStorage.getAccessToken()).called(1);
    verify(tokenStorage.getRefreshToken()).called(1);

    verifyNoMoreInteractions(tokenStorage);
    verifyNoMoreInteractions(dio);
  });
}
