import 'dart:async';

import 'package:dio/dio.dart';
import 'package:example/api/application_api.dart';
import 'package:example/api/models/user_response_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_network/api/base/APIEnvironment.dart';
import 'package:flutter_platform_network/api/base/TokenManager.dart';
import 'package:flutter_platform_network/api/base/interceptors/RefreshTokenInterceptor.dart';
import 'package:flutter_platform_network/debug/debug.dart';

void main() {
  configureErrorReporting();
  runApp(MyApp());
}

void configureErrorReporting() {
  FlutterError.onError = (FlutterErrorDetails details) async {
    print(details);
  };
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ApplicationAPI api;

  bool isLoading = false;
  StreamSubscription subscription;
  List<UserResponseModel> users = List();

  @override
  void initState() {
    super.initState();

    final tokenManager = TokenManager();
    APIEnvironment apiEnvironment =
        APIEnvironment(baseUrl: 'https://reqres.in/api/');
    final apiDio = Dio();
    final tokenDio = Dio();

    final refreshTokenDelegate = MockRefreshTokenInterceptorDelegate();

    api = _configureApi(
      refreshTokenDelegate: refreshTokenDelegate,
      apiDio: apiDio,
      tokenDio: tokenDio,
      apiEnvironment: apiEnvironment,
    );
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
        child: Icon(Icons.update),
      ),
    );
  }

  ApplicationAPI _configureApi({
    Dio apiDio,
    Dio tokenDio,
    APIEnvironment apiEnvironment,
    RefreshTokenInterceptorDelegate refreshTokenDelegate,
    List<Interceptor> interceptors = const [],
  }) {
    final refreshTokenInterceptor = RefreshTokenInterceptor(
      apiDio: apiDio,
      tokenDio: tokenDio,
      delegate: refreshTokenDelegate,
    );

    apiDio.options.baseUrl = apiEnvironment.baseUrl;
    apiDio.interceptors.add(refreshTokenInterceptor);

    apiDio.options.connectTimeout = 30 * 1000;
    apiDio.options.receiveTimeout = 60 * 1000;
    apiDio.options.sendTimeout = 60 * 1000;

    tokenDio.options.baseUrl = apiEnvironment.baseUrl;

    debug(() {
      apiDio.interceptors.addAll(interceptors);

      apiDio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
      tokenDio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    });

    return ApplicationAPI(environment: apiEnvironment, dio: apiDio);
  }

  void _loadUserList() async {
    await subscription?.cancel();

    subscription = api
        .getUserList()
        .doOnListen(() => setState(() => isLoading = true))
        .doOnDone(() => setState(() => isLoading = false))
        .listen((result) => setState(() => users = result.data),
            onError: (e) => showErrorDialog());
  }

  Widget getUsersWidget(List<UserResponseModel> users) {
    return ListView.separated(
      itemBuilder: (context, i) => _createUserItemWidget(users[i]),
      itemCount: users.length,
      separatorBuilder: (context, i) => Divider(),
    );
  }

  Widget _getProgressWidget() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _createUserItemWidget(UserResponseModel user) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(children: [
        CircleAvatar(
          backgroundColor: Colors.grey,
          backgroundImage: NetworkImage(user.avatar),
        ),
        SizedBox(
          width: 8,
        ),
        Text(
          user.id.toString(),
          style: Theme.of(context).textTheme.display1,
        ),
        SizedBox(
          width: 8,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              user.fullName,
              style: Theme.of(context).textTheme.subtitle,
            ),
            Text(
              user.email,
              style: Theme.of(context).textTheme.subhead,
            ),
          ],
        ),
      ]),
    );
  }

  void showErrorDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warning'),
          content: Text('An error occurred while loading data'),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class MockRefreshTokenInterceptorDelegate
    extends RefreshTokenInterceptorDelegate {
  noSuchMethod(Invocation invocation) => null;

  @override
  Future<bool> isAuthorised() {
    return Future.value(false);
  }
}
