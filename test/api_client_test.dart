import 'package:dash_kit_network/dash_kit_network.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'api_client_test.mocks.dart';
import 'api_client_test_utils.dart';
import 'test_components/test_api_client.dart';
import 'test_components/test_refresh_tokens_delegate.dart';

@GenerateMocks([TokenStorage, Dio])
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
      return Future.error(DioError(
        response: Response(
          statusCode: 401,
          request: RequestOptions(path: ''),
        ),
      ));
    });

    onRefreshRequestAnswer(dio, () {
      return Future.error(DioError(
          response: Response(
        statusCode: 400,
        request: RequestOptions(path: ''),
      )));
    });

    final usersRequest = apiClient.get(
      path: 'users',
      isAuthorisedRequest: true,
      responseMapper: (response) => response,
    );

    bool isRequestFailed = false;
    try {
      await usersRequest;
    } catch (e) {
      isRequestFailed = true;
    }

    expect(isRequestFailed, true, reason: 'Request should failed');

    verifyInOrder([
      dio.options,
      userRequest(dio, accessToken: ''),
      refreshTokensRequest(dio),
    ]);

    verify(tokenStorage.getAccessToken()).called(1);
    verify(tokenStorage.getRefreshToken()).called(1);

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
        request: RequestOptions(path: ''),
      ));
    });

    final users = await apiClient.get(
        path: 'users',
        isAuthorisedRequest: true,
        responseMapper: (response) => response);

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
      return Future.error(DioError(
          response: Response(
        statusCode: 403,
        request: RequestOptions(path: ''),
      )));
    });

    final usersRequest = apiClient.get(
      path: 'users',
      isAuthorisedRequest: true,
      responseMapper: (response) => response,
    );

    bool isRequestFailed = false;
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
        return Future.error(DioError(
            response: Response(
          statusCode: 401,
          request: RequestOptions(path: ''),
        )));
      }

      return Future.value(Response(
        statusCode: 200,
        data: ['John', 'Mary'],
        request: RequestOptions(path: ''),
      ));
    });

    onRefreshRequestAnswer(dio, () {
      return Future.value(Response(
        statusCode: 200,
        data: {
          'access_token': '<refreshed_access_token>',
          'refresh_token': '<refreshed_refresh_token>',
        },
        request: RequestOptions(path: ''),
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
      return Future.error(DioError(
          response: Response(
        statusCode: 401,
        request: RequestOptions(path: ''),
      )));
    });

    when(dio.post('refresh_tokens')).thenAnswer(
      (_) => Future.error(DioError(
          response: Response(
        statusCode: 401,
        request: RequestOptions(path: ''),
      ))),
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

    verify(tokenStorage.getAccessToken()).called(1);
    verify(tokenStorage.getRefreshToken()).called(1);

    verifyNoMoreInteractions(tokenStorage);
    verifyNoMoreInteractions(dio);
  });
}
