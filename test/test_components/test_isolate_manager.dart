import 'dart:async';

import 'package:dash_kit_network/dash_kit_network.dart';
import 'package:dash_kit_network/src/isolate_manager/isolate_manager_io/isolate_manager.dart'
    if (dart.library.html) 'package:dash_kit_network/src/isolate_manager/isolate_manager_web/isolate_manager.dart';
import 'package:dash_kit_network/src/models/request_params.dart';
import 'package:flutter/foundation.dart';

// This is necessary for tests, because we can't test count of executed methods
// in isolate.
class TestIsolateManager extends IsolateManager {
  TestIsolateManager() : super();

  int count = 0;

  @override
  Future<FutureOr<T>> sendTask<T>({
    required RequestParams params,
    required Options options,
    required Future<Response<T>> Function(
      String path, {
      CancelToken? cancelToken,
      Object? data,
      Options? options,
      Map<String, dynamic>? queryParameters,
    })
        dioMethod,
  }) async {
    if (!kIsWeb) {
      await dioMethod(
        params.path,
        data: params.body,
        queryParameters: params.queryParams,
        options: options,
        cancelToken: params.cancelToken,
      );
    }

    return super.sendTask(
      params: params,
      options: options,
      dioMethod: dioMethod,
    );
  }
}
