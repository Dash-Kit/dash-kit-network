import 'package:dash_kit_network/dash_kit_network.dart';
import 'package:example/api/application_api.dart';
import 'package:example/app.dart';
import 'package:flutter/material.dart';

void main() {
  final dio = Dio();

  const apiEnvironment = ApiEnvironment(
    baseUrl: 'https://reqres.in/api/',
    validateRequestsByDefault: false,
  );

  final apiClient = ApplicationApi(
    dio: dio,
    environment: apiEnvironment,
  );

  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));

  runApp(MyApp(
    apiClient: apiClient,
  ));
}
