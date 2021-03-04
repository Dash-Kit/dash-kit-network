// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:example/api/application_api.dart';
import 'package:example/app.dart';
import 'package:flutter/material.dart';
import 'package:dash_kit_network/dash_kit_network.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
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

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      apiClient: apiClient,
    ));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
