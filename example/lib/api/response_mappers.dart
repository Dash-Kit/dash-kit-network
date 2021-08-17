import 'package:dio/dio.dart';
import 'package:example/api/models/users_response_model.dart';

import 'models/errors/error_response_model.dart';

UsersResponseModel users(Response response) {
  if (response.statusCode == 200) {
    return UsersResponseModel.fromJson(response.data);
  }

  throw ResponseErrorModel.fromJson(response.data);
}
