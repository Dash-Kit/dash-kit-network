import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:dash_kit_network/dash_kit_network.dart';
import 'package:dash_kit_network/src/isolate_manager/isolate_manager_interface.dart';

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
  /// ```dart
  ///  IsolateManager isolateManager = IsolateManager();
  ///  await isolateManager.start();
  ///  final result = await isolateManager.send(
  ///   response: response,
  ///   mapper: responseMapper,
  ///  );
  /// ```
  @override
  Future<FutureOr<T>> sendTask<T>({
    required Response<dynamic> response,
    required FutureOr<T> Function(Response<dynamic>) mapper,
  }) async {
    await _managerReadyCompleter.future;
    await super.sendTask(response: response, mapper: mapper);
    final task = Task(response.hashCode.toString(), response, mapper);

    _sendPort.send(task);

    final result =
        await _resultStream.where((event) => event.id == task.id).first;

    if (result.error != null) {
      throw result.error!;
    }

    return result.result;
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
void _isolateFunction(SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  receivePort.listen(
    (message) async {
      assert(message is Task, 'Message should be, a Task');
      try {
        final result = await message.mapper(message.response);
        sendPort.send(Result(id: message.id, result: result));
      } catch (e, stackTrace) {
        log('Error: $e');
        log('$stackTrace');
        sendPort.send(Result(
          id: message.id,
          error: e,
        ));
      }
    },
  );
}
