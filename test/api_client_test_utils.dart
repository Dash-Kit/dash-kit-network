import 'package:dash_kit_network/dash_kit_network.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void stubAccessToken(TokenStorage tokenStorage, String accessToken) {
  when(tokenStorage.getAccessToken())
      .thenAnswer((_) => Future.value(accessToken));
}

void stubRefreshToken(TokenStorage tokenStorage, String refreshToken) {
  when(tokenStorage.getRefreshToken())
      .thenAnswer((_) => Future.value(refreshToken));
}

void stubDioOptions(Dio dio, BaseOptions options) {
  when(dio.options).thenReturn(options);
}

void onUserRequestAnswer(Dio dio, Future<Response<dynamic>> Function() answer) {
  when(
    dio.get(
      'users',
      queryParameters: anyNamed('queryParameters'),
      options: anyNamed('options'),
      cancelToken: anyNamed('cancelToken'),
    ),
  ).thenAnswer((_) => answer());
}

void onRefreshRequestAnswer(
  Dio dio,
  Future<Response<dynamic>> Function() answer,
) {
  when(dio.post('refresh_tokens')).thenAnswer((_) => answer());
}

Future<Response> userRequest(Dio dio, {String accessToken = ''}) {
  return dio.get(
    'users',
    queryParameters: anyNamed('queryParameters'),
    options: argThat(
      optionsWithAccessToken(accessToken),
      named: 'options',
    ),
    cancelToken: anyNamed('cancelToken'),
    onReceiveProgress: argThat(isNull, named: 'onReceiveProgress'),
  );
}

Future<Response> refreshTokensRequest(Dio dio) {
  return dio.post('refresh_tokens');
}

final Matcher Function(bool Function(Options)) optionsThat = (matcher) {
  return _OptionsMatcher(matcher);
};

final Matcher Function(String) optionsWithAccessToken = (accessToken) {
  return optionsThat(
    (o) => o.headers?['Authorization'] == 'Bearer $accessToken',
  );
};

class _OptionsMatcher extends Matcher {
  const _OptionsMatcher(this.matcher);

  final bool Function(Options options) matcher;

  @override
  bool matches(item, Map matchState) => matcher(item);
  @override
  Description describe(Description description) =>
      description.add('request options');
}
