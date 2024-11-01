import 'dart:async';

import 'package:example/api/application_api.dart';
import 'package:example/api/models/user_response_model.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    required this.apiClient,
    Key? key,
  }) : super(key: key);

  final ApplicationApi apiClient;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Platform Network Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'Flutter Platform Network Page',
        apiClient: apiClient,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    required this.title,
    required this.apiClient,
    Key? key,
  }) : super(key: key);

  final String title;
  final ApplicationApi apiClient;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = false;
  StreamSubscription? subscription;
  List<UserResponseModel> users = [];
  int currentPage = 1;

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
      body: LayoutBuilder(builder: (context, constraints) {
        return isLoading
            ? _getProgressWidget()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: constraints.maxHeight * 0.8,
                    child: getUsersWidget(users),
                  ),
                  const Spacer(),
                  MaterialButton(
                    padding: const EdgeInsets.all(10),
                    color: Colors.blueAccent,
                    onPressed: _loadNextPage,
                    minWidth: constraints.maxWidth * 0.9,
                    child: const Text('Get next users'),
                  ),
                  const SizedBox(height: 8),
                  MaterialButton(
                    padding: const EdgeInsets.all(10),
                    color: Colors.red,
                    onPressed: _loadErrorPage,
                    minWidth: constraints.maxWidth * 0.9,
                    child: const Text('Error request'),
                  ),
                  const Spacer(),
                ],
              );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadUserList,
        tooltip: 'Load a user list',
        child: const Icon(Icons.update),
      ),
    );
  }

  Widget getUsersWidget(List<UserResponseModel> users) {
    return ListView.separated(
      itemBuilder: (context, i) => _createUserItemWidget(users[i]),
      itemCount: users.length,
      separatorBuilder: (context, i) => const Divider(),
    );
  }

  void showErrorDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Warning'),
          content: const Text('An error occurred while loading data'),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _createUserItemWidget(UserResponseModel user) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(children: [
        CircleAvatar(
          backgroundColor: Colors.grey,
          backgroundImage: NetworkImage(user.avatar),
        ),
        const SizedBox(width: 8),
        Text(
          user.id.toString(),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              user.fullName,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              user.email,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ]),
    );
  }

  Widget _getProgressWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Future<void> _loadUserList() async {
    await subscription?.cancel();

    setState(() => isLoading = true);

    try {
      final response = await widget.apiClient.getUserList();
      users = response.data;
    } catch (e) {
      showErrorDialog();
    }

    setState(() => isLoading = false);
  }

  Future<void> _loadNextPage() async {
    await subscription?.cancel();

    setState(() => isLoading = true);

    try {
      currentPage++;
      final response = await widget.apiClient.getUserList(page: currentPage);
      users.addAll(response.data);
    } catch (e) {
      showErrorDialog();
    }

    setState(() => isLoading = false);
  }

  Future<void> _loadErrorPage() async {
    await subscription?.cancel();

    setState(() => isLoading = true);

    try {
      await widget.apiClient.getErrorRequest();
    } catch (e) {
      showErrorDialog();
    }

    setState(() => isLoading = false);
  }
}
