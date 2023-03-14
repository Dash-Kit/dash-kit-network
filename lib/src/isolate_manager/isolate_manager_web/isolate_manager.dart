import 'dart:async';

import 'package:dash_kit_network/dash_kit_network.dart';
import 'package:dash_kit_network/src/isolate_manager/isolate_manager_interface.dart';

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
  /// Instead the `send` method executes the mapper function and returns result.
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
    await super.sendTask(response: response, mapper: mapper);

    return mapper(response);
  }
}
