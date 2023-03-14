# Isolate parsing performance

Parsing JSON on an isolate allows you to perform the operation in the background without blocking the main thread, which can be useful for large JSON files or when you need to perform other operations while parsing.

**Parse on main thread took 20-60 microseconds.**

**Parse using IsolateManager took 2400-2500 microseconds.**

**Parse using Isolate.run took 110000-130000 microseconds.**

```dart
Future<T> executeInIsolate<T>({
  required T Function(Response) mapper,
  required Response response,
}) {
  return Isolate.run(() => mapper.call(response));
}
```

These results were obtained :

```dart
    final performRequest = (tokenPair) async {
      final response = await _createRequest(params, tokenPair);

      final timer = Stopwatch()..start();
      params.responseMapper.call(response);
      log('Sync mapper: ${timer.elapsedMicroseconds}');
      timer.stop();

      final timer2 = Stopwatch()..start();
      final result = await isolateManager.send(response, params.responseMapper);
      log('isolateManager.send: ${timer2.elapsedMicroseconds}');
      timer2.stop();

      final timer3 = Stopwatch()..start();
      await executeInIsolate(mapper: params.responseMapper, response: response);
      log('execute in Isolate.run: ${timer3.elapsedMicroseconds}');
      timer3.stop();

      return result;
    };
```
