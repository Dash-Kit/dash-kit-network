import 'dart:async';

import 'package:dash_kit_network/dash_kit_network.dart';
import 'package:dash_kit_network/src/models/request_params.dart';
import 'package:flutter/foundation.dart';

/// This is an abstract class for managing isolates.
///
/// It defines the basic methods needed to start, stop, and send messages
/// to an isolate. Flutter Web doesn't support isolates, so the `IsolateManager`
/// class has a different implementation for the web.
abstract class IsolateManagerInterface {
  IsolateStatus _isolateStatus = IsolateStatus.created;

  /// Method for starting the isolate.
  ///
  /// Should be called before sending messages. If `start()` is called multiple
  /// times, an assertion error is thrown.
  @mustCallSuper
  Future<void> start() async {
    assert(_isolateStatus == IsolateStatus.created, 'Isolate already started');
    _isolateStatus = IsolateStatus.initializing;

    return;
  }

  /// Method for stopping the isolate.
  ///
  /// Should be called when the isolate is no longer needed.
  /// Throws an assertion error if the isolate is not started.
  @mustCallSuper
  void stop() {
    assert(
        _isolateStatus == IsolateStatus.initializing ||
            _isolateStatus == IsolateStatus.initialized,
        'Isolate not started');
    _isolateStatus = IsolateStatus.stopped;
  }

  /// Method for sending a [Task] to the isolate.
  ///
  /// This method get the [RequestParams], [Options] and the [Dio] method and
  /// creates a [Task] object. The [Task] object is sent to the isolate and the
  /// [ResponseMapper] function is executed in the isolate.
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
  @mustCallSuper
  Future sendTask<T>({
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
  }) {
    assert(
      _isolateStatus == IsolateStatus.initialized ||
          _isolateStatus == IsolateStatus.created ||
          _isolateStatus == IsolateStatus.initializing,
      'Isolate should be launched',
    );

    return Future.value();
  }

  /// Change the isolate status to initialized.
  @protected
  @mustCallSuper
  void setInitializedStatus() {
    _isolateStatus = IsolateStatus.initialized;
  }
}

abstract class Task {
  const Task({required this.id});

  final String id;
}

/// The [WorkTask] class is used to store the data needed to execute the mapper
/// function in the isolate.
class WorkTask<T> implements Task {
  const WorkTask({
    required this.id,
    required this.params,
    required this.options,
    required this.dioMethod,
    required this.needCancelToken,
  });

  @override
  final String id;
  final RequestParams params;
  final Options options;
  final Future<Response<T>> Function(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) dioMethod;
  final bool needCancelToken;

  @override
  String toString() {
    return 'Task{id: $id, params: $params, options: $options, '
        'dioMethod: $dioMethod, cancelToken: $needCancelToken}';
  }
}

class CancelTask implements Task {
  CancelTask({
    required this.id,
    required this.error,
  });

  @override
  final String id;
  final DioError error;
}

/// The [Result] class is used to store the result of the mapper function
/// execution in the isolate.
class Result<T> {
  const Result({
    required this.id,
    this.result,
    this.error,
  });

  final String id;
  final T? result;
  final dynamic error;

  @override
  String toString() {
    return 'Result{id: $id, result: $result, error: $error}';
  }
}

/// The [IsolateStatus] enum is used to track the status of the isolate.
enum IsolateStatus {
  created,
  initializing,
  initialized,
  stopped,
}
