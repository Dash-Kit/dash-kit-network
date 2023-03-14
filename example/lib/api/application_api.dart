import 'package:dash_kit_network/dash_kit_network.dart';
import 'package:example/api/models/login_response_model.dart';
import 'package:example/api/models/users_response_model.dart';
import 'package:example/api/response_mappers.dart' as response_mappers;

class ApplicationApi extends ApiClient {
  ApplicationApi({
    required ApiEnvironment environment,
    required Dio dio,
  }) : super(
          environment: environment,
          dio: dio,
        );

  Future<UsersResponseModel> getUserList({int? page}) => get(
        path: 'users${page != null ? '?page=$page' : ''}',
        responseMapper: response_mappers.users,
        validate: false,
        receiveTimeout: Duration(seconds: 30),
        sendTimeout: Duration(seconds: 30),
      );

  Future<LoginResponseModel> saveAuthTokens(LoginResponseModel response) {
    return updateAuthTokens(
      TokenPair(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      ),
    ).then((value) => response).onError((error, stackTrace) {
      return Future.error(error!);
    });
  }

  Future<void> getErrorRequest() => get(
        path: 'users/23',
        responseMapper: response_mappers.users,
        validate: false,
        receiveTimeout: Duration(seconds: 30),
        sendTimeout: Duration(seconds: 30),
      );
}
