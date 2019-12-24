import 'package:flutter_platform_network/src/models/token_pair.dart';
import 'package:rxdart/rxdart.dart';

typedef TokenRefresher = Observable<TokenPair> Function(TokenPair tokenPair);
