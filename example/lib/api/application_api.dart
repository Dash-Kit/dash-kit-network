import 'package:example/api/models/users_response_model.dart';
import 'package:example/api/response_mappers.dart' as responseMappers;
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_platform_network/flutter_platform_network.dart';

class ApplicationApi extends ApiClient {
  ApplicationApi({
    @required ApiEnvironment environment,
    @required Dio dio,
  }) : super(environment: environment, dio: dio);

  Observable<UsersResponseModel> getUserList() => get(
        path: 'users',
        responseMapper: responseMappers.users,
        validate: false,
      );
}
