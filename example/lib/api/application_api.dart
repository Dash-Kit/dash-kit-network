import 'package:example/api/models/users_response_model.dart';
import 'package:example/api/response_mappers.dart' as response_mappers;
import 'package:dio/dio.dart';
import 'package:dash_kit_network/dash_kit_network.dart';

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
}
