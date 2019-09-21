import 'package:example/api/models/errors/error_response_model.dart';
import 'package:example/api/models/users_response_model.dart';
import 'package:dio/dio.dart';

UsersResponseModel users(Response response) {
  if (response.statusCode == 200) {
    return UsersResponseModel.fromJson(response.data);
  } else {
    throw ResponseErrorModel.fromJson(response.data);
  }
}