import 'package:example/app.dart';
import 'package:flutter/material.dart';
import 'package:dash_kit_network/dash_kit_network.dart';

import 'api/application_api.dart';

void main() {
  final dio = Dio();

  const apiEnvironment = ApiEnvironment(
    baseUrl: 'https://reqres.in/api/',
    validateRequestsByDefault: false,
    isRequestsAuthorisedByDefault: false,
  );

  final apiClient = ApplicationApi(
    dio: dio,
    environment: apiEnvironment,
  );

  dio.interceptors.add(LogInterceptor(
    request: true,
    requestBody: true,
    requestHeader: true,
    responseBody: true,
  ));

  runApp(MyApp(
    apiClient: apiClient,
  ));
}
