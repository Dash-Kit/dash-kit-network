import 'package:dash_kit_network/dash_kit_network.dart';

import 'test_isolate_manager.dart';

class TestApiClient extends ApiClient {
  TestApiClient(Dio dio, RefreshTokensDelegate delegate)
      : super(
          environment: const ApiEnvironment(baseUrl: 'https://base-url.com'),
          dio: dio,
          delegate: delegate,
          externalIsolateManager: TestIsolateManager(),
        );
}
