import 'dart:async';

import 'package:dash_kit_network/dash_kit_network.dart';
import 'package:dash_kit_network/src/isolate_manager/isolate_manager_interface.dart';
import 'package:dash_kit_network/src/models/request_params.dart';

///  The IsolateManager class implements the IsolateManagerInterface.
///
/// Provides an interface for managing isolates in the DashKit network library
/// in web environment.
class IsolateManager extends IsolateManagerInterface {
  /// The start() method sets the isolate status to initialized.
  ///
  /// If `start()` is called multiple times, an assertion error is thrown.
  /// In web environment the `start()` method doesn't do anything.
  @override
  Future<void> start() async {
    await super.start();
    setInitializedStatus();
  }

  /// Implementation for web environment where isolates aren't available.
  ///
  /// Instead the `dioMethod` is called directly. Is waited response,is called
  /// `responseMapper` and is returned `responseMapper` result.
  ///
  /// ```dart
  ///  IsolateManager isolateManager = IsolateManager();
  ///  await isolateManager.start();
  ///  final result = await isolateManager.sendTask(
  ///    params: requestParams,
  ///    options: options,
  ///    dioMethod: dio.get,
  ///    cancelToken: cancelToken,
  ///  );
  /// ```
  @override
  Future<FutureOr<T>> sendTask<T>({
    required RequestParams params,
    required Options options,
    required Future<Response<T>> Function(
      String path, {
      Object? data,
      Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken,
    })
        dioMethod,
  }) async {
    await super
        .sendTask(params: params, options: options, dioMethod: dioMethod);
    final completer = Completer<T>();

    try {
      final response = await dioMethod(
        params.path,
        data: params.body,
        queryParameters: params.queryParams,
        options: options,
        cancelToken: params.cancelToken,
      );
      completer.complete(await params.responseMapper(response));
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future;
  }
}
