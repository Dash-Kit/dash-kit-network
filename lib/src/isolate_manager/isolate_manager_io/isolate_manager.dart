import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:dash_kit_network/dash_kit_network.dart';
import 'package:dash_kit_network/src/isolate_manager/isolate_manager_interface.dart';
import 'package:dash_kit_network/src/models/request_params.dart';
import 'package:flutter/foundation.dart';

/// The `IsolateManager` class manages a separate isolate for executing tasks
/// asynchronously. It implements the `IsolateManagerInterface` interface,
/// which is not shown here.
class IsolateManager extends IsolateManagerInterface {
  late final Stream<Result> _resultStream;
  late final StreamSubscription _errorSubscription;
  late final StreamSubscription _exitSubscription;
  late final Isolate _isolate;
  late final SendPort _sendPort;

  final _receivePort = ReceivePort();
  final _errorPort = ReceivePort();
  final _exitPort = ReceivePort();
  final Completer<void> _managerReadyCompleter = Completer<void>();

  /// `start()` initializes the isolate and sets up listeners for errors and
  /// exit events.
  ///
  /// It waits for the `sendPort` from the isolate to be received
  /// before setting `_sendPort` and completing `_managerReadyCompleter.
  @override
  Future<void> start() async {
    await super.start();
    final stream = _receivePort.asBroadcastStream();
    _resultStream = stream.where((message) => message is Result).cast<Result>();
    _isolate = await Isolate.spawn(
      _isolateFunction,
      _receivePort.sendPort,
      errorsAreFatal: false,
      onError: _errorPort.sendPort,
      onExit: _exitPort.sendPort,
    );
    _errorSubscription = _errorPort.listen((message) {
      log('isolate manager error: $message');
    });
    _exitSubscription = _exitPort.listen((message) {
      log('isolate manager exit: $message');
      _errorSubscription.cancel();
    });

    final sendPortMessage = await stream.first;
    _handleSendPortMessage(sendPortMessage);
  }

  /// Stops the isolate.
  ///
  /// Kill isolate and cancel error and exit subscription.
  /// Start again after stop is impossible.
  @override
  void stop() {
    super.stop();
    _isolate.kill(priority: Isolate.immediate);
    _errorSubscription.cancel();
    _exitSubscription.cancel();
  }

  /// Sends a [Task] to the isolate.
  ///
  /// Waits for _managerReadyCompleter to complete before sending the task.
  /// Throws an error if the result contains an error.
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
    await _managerReadyCompleter.future;
    await super.sendTask(
      params: params,
      options: options,
      dioMethod: dioMethod,
    );
    final completer = Completer<T>();
    final task = WorkTask(
      id: UniqueKey().toString(),
      params: params.isolateInstance,
      options: options,
      dioMethod: dioMethod,
      needCancelToken: params.cancelToken != null,
    );

    // ignore: unawaited_futures
    params.cancelToken?.whenCancel.then((err) {
      completer.completeError(err);
      final cancelTask = CancelTask(id: task.id, error: err);
      _sendPort.send(cancelTask);
      log('Request was canceled: $err', name: 'IsolateManager');
    });

    try {
      _sendPort.send(task);
    } catch (e, stackTrace) {
      log('$e,\n $stackTrace', name: 'SendPort.send');
      completer.completeError(e);
    }

    unawaited(_resultStream
        .where((event) => event.id == task.id)
        .first
        .then((result) {
      if (result.error != null) {
        if (completer.isCompleted) {
          return;
        }
        completer.completeError(result.error!);
      } else {
        completer.complete(result.result);
      }
    }));

    return completer.future;
  }

  /// Handles incoming messages from the isolate.
  ///
  /// If the message is a [SendPort], sets the `_sendPort`, completes the
  /// `_managerReadyCompleter`.
  void _handleSendPortMessage(dynamic message) {
    assert(message is SendPort, 'The first message should be a SendPort');
    _sendPort = message;
    _managerReadyCompleter.complete();
    setInitializedStatus();
  }
}

/// Listen for messages from the isolate manager.
///
/// We shouldn't store and cancel subscription, because the isolate will be
/// killed after `IsolateManager.stop` is called.
// ignore: long-method
void _isolateFunction(SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);
  final cancelTokensMap = <String, CancelToken>{};

  receivePort.listen(
    (message) async {
      assert(message is Task, 'Message should be, a Task');
      if (message is WorkTask) {
        if (message.needCancelToken) {
          cancelTokensMap[message.id] = CancelToken();
        }
        try {
          final response = await message.dioMethod(
            message.params.path,
            data: message.params.body,
            queryParameters: message.params.queryParams,
            options: message.options,
            cancelToken: cancelTokensMap[message.id],
          );
          final result = await message.params.responseMapper(response);
          sendPort.send(Result(id: message.id, result: result));
        } catch (e, stackTrace) {
          log('Error: $e', name: 'isolateFunction');
          log('$stackTrace', name: 'isolateFunction');
          sendPort.send(Result(
            id: message.id,
            error: e,
          ));
        }
      }
      if (message is CancelTask) {
        final cancelToken = cancelTokensMap.remove(message.id);
        if (cancelToken != null) {
          cancelToken.cancel();
        }
      }
    },
    cancelOnError: false,
  );
}
