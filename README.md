# Dash-Kit Network

<img src="https://github.com/Dash-Kit/dash-kit-network/blob/master/images/Dash-Kit%20Networking.png?raw=true" alt="drawing" width="550"/> &nbsp;

The Dash-Kit plugin includes Http requests Api (based on [Dio Http client](https://pub.dev/packages/dio)) and provides core features for work with network functionality, including token refresh.

---
</br>

## Install

To use this plugin, add ```dash_kit_network``` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/packages-and-plugins/using-packages).

---
</br>

## Description

</br>

**1)** First step is to create Application Api file for your project to store all required api requests. This file should extend ApiClient component.

```dart
import 'package:example/api/response_mappers.dart' as response_mappers;

class ApplicationApi extends ApiClient {
  ApplicationApi({
    required ApiEnvironment environment,
    required Dio dio,
  }) : super(environment: environment, dio: dio);

}
```

</br>

**2)** Next, it requires to initialize your Application Api instance in ``main.dart`` using Dio and App Environment instances as parameters and pass created instance to your Flutter app (as an alternative, it is also possible to use any Service Locator for getting an access to your Application Api from your UI without passing an instance trough widgets).

```dart
import 'package:dash_kit_network/dash_kit_network.dart';
import 'package:example/app.dart';
import 'package:flutter/material.dart';

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
```

</br>

**3)** To convert the received data from network response (basically in JSON format) into a custom Dart objects it requires to create appropriate response models. You may use [JsonSerializable](https://pub.dev/packages/json_serializable) or [Freezed](https://pub.dev/packages/freezed) builders for creating models that will handle JSON data.

```dart
part 'user_response_model.g.dart';

@JsonSerializable()
class UserResponseModel {
  UserResponseModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.avatar,
  });

  factory UserResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UserResponseModelFromJson(json);

  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String avatar;

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toJson() => _$UserResponseModelToJson(this);
}
```

```dart
part 'users_response_model.g.dart';

@JsonSerializable()
class UsersResponseModel {
  UsersResponseModel({
    required this.data,
  });

  factory UsersResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UsersResponseModelFromJson(json);

  final List<UserResponseModel> data;

  Map<String, dynamic> toJson() => _$UsersResponseModelToJson(this);
}
```

</br>

**4)** Additionally you need to create Response Mapper to handle request completion.

```dart
UsersResponseModel users(Response response) {
  if (response.statusCode == 200) {
    return UsersResponseModel.fromJson(response.data);
  }

  throw ResponseErrorModel.fromJson(response.data);
}
```

</br>

**5)** After preparing required Response Models and Response Mappers you may declare required requests inside Application Api file by creating methods that will return Feature with type of created Response Model. These methods should use one of Api methods:

- **get** - used to request data from a specified resource
- **post** - used to send data to a server to create/update a resource
- **put** - used to send data to a server to create/update a resource (PUT method is called when you have to modify a single resource while POST method is called when you have to add a child resource).
- **patch** - used to make partial update of a resource
- **delete** - used to delete the specified resource
- **updateAuthTokens** - updates tokens pair in token storage using token manager
- **clearAuthTokens** - removing tokens from token storage
- **isAuthorized** - verify if user is authorized by checking if token storage is not empty.

```dart
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
```

</br>

**6)** Finally, you just need calling created network request from required place of your app.

```dart
class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = false;
  StreamSubscription? subscription;
  List<UserResponseModel> users = [];

  @override
  void initState() {
    super.initState();

    _loadUserList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: isLoading ? _getProgressWidget() : getUsersWidget(users),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadUserList,
        tooltip: 'Load a user list',
        child: const Icon(Icons.update),
      ),
    );
  }

  {...rest of the code...}

  Future<void> _loadUserList() async {
    subscription?.cancel();

    setState(() => isLoading = true);

    try {
      final response = await widget.apiClient.getUserList();
      users = response.data;
    } catch (e) {
      showErrorDialog();
    }

    setState(() => isLoading = false);
  }
}
```

---
</br>

## Example

You can also check the [example project](https://github.com/Dash-Kit/dash-kit-network/tree/master/example).
