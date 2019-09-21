import 'package:example/api/models/users_response_model.dart';
import 'package:example/api/response_mappers.dart' as responseMappers;
import 'package:flutter/foundation.dart';
import 'package:flutter_platform_network/api/base/api.dart';
import 'package:flutter_platform_network/api/base/api_environment.dart';
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';

class ApplicationAPI extends API {

  ApplicationAPI({
    @required APIEnvironment environment,
    @required Dio dio,
  }) : super(environment: environment, dio: dio);

  Observable<UsersResponseModel> getUserList() =>
      get(
        path: 'users',
        responseMapper: responseMappers.users,
        validate: false,
      );
}