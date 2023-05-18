import 'package:dash_kit_network/dash_kit_network.dart';
import 'package:dash_kit_network/src/isolate_manager/isolate_manager_io/isolate_manager.dart'
    if (dart.library.html) 'package:dash_kit_network/src/isolate_manager/isolate_manager_web/isolate_manager.dart';
import 'package:dash_kit_network/src/models/request_params.dart';
import 'package:flutter_test/flutter_test.dart';

// ignore_for_file: avoid-unused-parameters

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
    await Future.delayed(const Duration(seconds: 1));
    if (response.statusCode == 200) {
      return response.data;
    }

    throw DioError.badResponse(
      statusCode: response.statusCode,
      requestOptions: response.requestOptions,
      response: response,
    );
  };

  final params = RequestParams(
    method: HttpMethod.get,
    path: '',
    headers: [],
    responseMapper: asyncMapper,
    isAuthorisedRequest: false,
    validate: false,
  );

  Future<Response> dioMethod(
    String? path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    if (cancelToken?.cancelError != null) {
      throw cancelToken!.cancelError!;
    }

    return response;
  }

  Future<Response> dioMethodError(
    String? path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await Future.delayed(Duration.zero);

    return errorResponse;
  }

  test('Isolate manager send request before start', () {
    final isolateManager = IsolateManager();
    isolateManager
        .sendTask(
          params: params,
          options: Options(),
          dioMethod: dioMethod,
        )
        .then((value) => expect(value, response.data));
    isolateManager.start();
  });

  test('Isolate manager error response', () async {
    final isolateManager = IsolateManager();
    await isolateManager.start();
    await expectLater(
      isolateManager.sendTask(
        params: params,
        options: Options(),
        dioMethod: dioMethodError,
      ),
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
    final result = await isolateManager.sendTask(
      params: params,
      options: Options(),
      dioMethod: dioMethod,
    );
    expect(result, response.data);
    isolateManager.stop();
    await expectLater(isolateManager.start(), throwsA(isA<AssertionError>()));
  });

  test('Isolate stopped twice', () async {
    final isolateManager = IsolateManager();
    await isolateManager.start();
    final result = await isolateManager.sendTask(
      params: params,
      options: Options(),
      dioMethod: dioMethod,
    );
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
    final result = await isolateManager.sendTask(
      params: params,
      options: Options(),
      dioMethod: dioMethod,
    );
    expect(result, response.data);
    expect(isolateManager.stop, isA<void>());
  });

  test('Isolate send after stopped', () async {
    final isolateManager = IsolateManager();
    await isolateManager.start();
    final result = await isolateManager.sendTask(
      params: params,
      options: Options(),
      dioMethod: dioMethod,
    );
    expect(result, response.data);
    isolateManager.stop();
    await expectLater(
      isolateManager.sendTask(
        params: params,
        options: Options(),
        dioMethod: dioMethod,
      ),
      throwsA(isA<AssertionError>()),
    );
  });

  test('Isolate cancel request', () async {
    final isolateManager = IsolateManager();
    final paramsWithCancelToken = RequestParams(
      method: HttpMethod.get,
      path: '',
      headers: [],
      responseMapper: asyncMapper,
      isAuthorisedRequest: false,
      validate: false,
      cancelToken: CancelToken(),
    );

    await isolateManager.start();
    final result = await isolateManager.sendTask(
      params: params,
      options: Options(),
      dioMethod: dioMethod,
    );
    expect(result, response.data);
    Future.delayed(const Duration(milliseconds: 200), () {
      paramsWithCancelToken.cancelToken?.cancel();
    });
    await expectLater(
      isolateManager.sendTask(
        params: paramsWithCancelToken,
        options: Options(),
        dioMethod: dioMethod,
      ),
      throwsA(isA<DioError>()),
    );
  });
}
