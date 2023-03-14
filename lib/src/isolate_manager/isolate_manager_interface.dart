import 'dart:async';

import 'package:dash_kit_network/dash_kit_network.dart';
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
  @protected
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
  @protected
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
  /// This method get a `response` and a `mapper` as parameters.
  /// The response [Response] is a response from the network request.
  /// The mapper [FutureOr<T> Function(Response<dynamic>)] is a function that
  /// takes a [Response] and returns a [FutureOr<T>].
  ///
  /// ```dart
  ///  IsolateManager isolateManager = IsolateManager();
  ///  await isolateManager.start();
  ///  final result = await isolateManager.send(
  ///   response: response,
  ///   mapper: responseMapper,
  ///  );
  /// ```
  @protected
  @mustCallSuper
  Future sendTask<T>({
    required Response<dynamic> response,
    required FutureOr<T> Function(Response<dynamic>) mapper,
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

/// The [Task] class is used to store the data needed to execute the mapper
/// function in the isolate.
class Task<T> {
  const Task(
    this.id,
    this.response,
    this.mapper,
  );

  final String id;
  final Response<dynamic> response;
  final T Function(Response<dynamic>) mapper;

  @override
  String toString() {
    return 'Task{id: $id, response: $response, mapper: $mapper}';
  }
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
