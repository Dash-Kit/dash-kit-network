import 'package:dash_kit_network/src/models/token_pair.dart';

typedef TokenRefresher = Future<TokenPair> Function(TokenPair tokenPair);
