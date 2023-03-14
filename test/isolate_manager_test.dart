import 'package:dash_kit_network/dash_kit_network.dart';
import 'package:dash_kit_network/src/isolate_manager/isolate_manager_io/isolate_manager.dart'
    if (dart.library.html) 'package:dash_kit_network/src/isolate_manager/isolate_manager_web/isolate_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final response = Response(
    statusCode: 200,
    data: ['John', 'Mary'],
    requestOptions: RequestOptions(),
  );

  final errorResponse = Response(
    statusCode: 400,
    data: {'error': 'Bad request'},
    requestOptions: RequestOptions(),
  );

  final asyncMapper = (response) async {
    await Future.delayed(Duration.zero);
    if (response.statusCode == 200) {
      return response.data;
    }

    throw DioError.badResponse(
      statusCode: response.statusCode,
      requestOptions: response.requestOptions,
      response: response,
    );
  };

  final syncMapper = (response) {
    if (response.statusCode == 200) {
      return response.data;
    }

    throw DioError.badResponse(
      statusCode: response.statusCode,
      requestOptions: response.requestOptions,
      response: response,
    );
  };

  test('Isolate manager send request before start', () {
    final isolateManager = IsolateManager();
    isolateManager
        .sendTask(response: response, mapper: syncMapper)
        .then((value) => expect(value, response.data));
    isolateManager.start();
  });

  test('Isolate manager async mapper', () async {
    final isolateManager = IsolateManager();
    await isolateManager.start();
    final result = await isolateManager.sendTask(
      response: response,
      mapper: asyncMapper,
    );
    expect(result, response.data);
  });

  test('Isolate manager error response', () async {
    final isolateManager = IsolateManager();
    await isolateManager.start();
    await expectLater(
      isolateManager.sendTask(response: errorResponse, mapper: asyncMapper),
      throwsA(isA<DioError>()),
    );
  });

  test('Isolate manager initialize twice assertion', () async {
    final isolateManager = IsolateManager();
    await isolateManager.start();
    await expectLater(isolateManager.start(), throwsA(isA<AssertionError>()));
  });

  test('Isolate after start and stop', () async {
    final isolateManager = IsolateManager();
    await isolateManager.start();
    final result =
        await isolateManager.sendTask(response: response, mapper: asyncMapper);
    expect(result, response.data);
    isolateManager.stop();
    await expectLater(isolateManager.start(), throwsA(isA<AssertionError>()));
  });

  test('Isolate stopped twice', () async {
    final isolateManager = IsolateManager();
    await isolateManager.start();
    final result =
        await isolateManager.sendTask(response: response, mapper: asyncMapper);
    expect(result, response.data);
    isolateManager.stop();
    expect(isolateManager.stop, throwsA(isA<AssertionError>()));
  });

  test('Isolate stopped before start', () {
    final isolateManager = IsolateManager();
    expect(isolateManager.stop, throwsA(isA<AssertionError>()));
  });

  test('Isolate stopped', () async {
    final isolateManager = IsolateManager();
    await isolateManager.start();
    final result =
        await isolateManager.sendTask(response: response, mapper: asyncMapper);
    expect(result, response.data);
    expect(isolateManager.stop, isA<void>());
  });

  test('Isolate send after stopped', () async {
    final isolateManager = IsolateManager();
    await isolateManager.start();
    final result =
        await isolateManager.sendTask(response: response, mapper: asyncMapper);
    expect(result, response.data);
    isolateManager.stop();
    await expectLater(
      isolateManager.sendTask(response: response, mapper: syncMapper),
      throwsA(isA<AssertionError>()),
    );
  });
}
