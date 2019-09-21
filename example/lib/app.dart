import 'dart:async';

import 'package:dio/dio.dart';
import 'package:example/api/application_api.dart';
import 'package:example/api/mock_refresh_token_delegate.dart';
import 'package:example/api/models/user_response_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_network/api/base/api_environment.dart';
import 'package:flutter_platform_network/api/base/token_manager.dart';
import 'package:flutter_platform_network/api/base/api_module.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Platform Network Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Platform Network Page'),
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
  ApiModule<ApplicationAPI> apiModule;

  bool isLoading = false;
  StreamSubscription subscription;
  List<UserResponseModel> users = List();

  @override
  void initState() {
    super.initState();

    _configureApiModule();
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
        child: Icon(Icons.update),
      ),
    );
  }

  void _loadUserList() async {
    await subscription?.cancel();

    subscription = apiModule.api
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

  void _configureApiModule() {
    final tokenManager = TokenManager();
    final apiEnvironment = APIEnvironment(baseUrl: 'https://reqres.in/api/');
    final apiDio = Dio();
    final tokenDio = Dio();

    final refreshTokenDelegate = MockRefreshTokenInterceptorDelegate(
      apiDio: apiDio,
      tokenDio: tokenDio,
      tokenManager: tokenManager,
    );

    apiModule = ApiModule<ApplicationAPI>(
      refreshTokenDelegate: refreshTokenDelegate,
      apiDio: apiDio,
      tokenDio: tokenDio,
      apiEnvironment: apiEnvironment,
      apiCreator: (environment, dio) => ApplicationAPI(
        environment: environment,
        dio: dio,
      ),
    );
  }
}
