import 'package:dash_kit_network/dash_kit_network.dart';
import 'package:example/api/models/login_response_model.dart';
import 'package:example/api/models/users_response_model.dart';
import 'package:example/api/response_mappers.dart' as response_mappers;

class ApplicationApi extends ApiClient {
  ApplicationApi({
    required ApiEnvironment environment,
    required Dio dio,
  }) : super(environment: environment, dio: dio);

  Future<UsersResponseModel> getUserList() => get(
        path: 'users',
        responseMapper: response_mappers.users,
        validate: false,
        connectTimeout: 30,
        receiveTimeout: 30,
        sendTimeout: 30,
      );

  Future<LoginResponseModel> saveAuthTokens(LoginResponseModel response) {
    return updateAuthTokens(
      TokenPair(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      ),
    ).then((value) => response).onError((error, stackTrace) {
      print(error);
      return Future.error(error!);
    });
  }
}
