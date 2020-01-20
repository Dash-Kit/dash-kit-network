import 'dart:math';

import 'package:flutter_platform_network/flutter_platform_network.dart';
import 'package:flutter_platform_network/src/token_manager.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  final TokenRefresher emptyTokenRefresher =
      (tokenPair) => Observable.fromFuture(Future.value(null));

  setUp(() async {});

  test('Initial tokens must be empty', () async {
    final tokenManager = TokenManager(tokenRefresher: emptyTokenRefresher);
    final tokenPair = await tokenManager.getTokens().first;

    expect(tokenPair.accessToken, '');
    expect(tokenPair.refreshToken, '');
  });

  test('Check initialization with tokens', () async {
    const initialTokenPair = TokenPair(
      accessToken: '<access_token>',
      refreshToken: '<refresh_token>',
    );

    final tokenManager = TokenManager(
      tokenRefresher: emptyTokenRefresher,
      tokenPair: initialTokenPair,
    );

    final tokenPair = await tokenManager.getTokens().first;

    expect(tokenPair.accessToken, initialTokenPair.accessToken);
    expect(tokenPair.refreshToken, initialTokenPair.refreshToken);
  });

  test('Check updating tokens', () async {
    final tokenManager = TokenManager(tokenRefresher: emptyTokenRefresher);

    const newTokenPair = TokenPair(
      accessToken: '<access_token>',
      refreshToken: '<refresh_token>',
    );

    tokenManager.updateTokens(newTokenPair);

    final tokenPair = await tokenManager.getTokens().first;

    expect(tokenPair.accessToken, newTokenPair.accessToken);
    expect(tokenPair.refreshToken, newTokenPair.refreshToken);
  });

  test(
      'Check tokens after refreshing '
      '(must return refreshed token after starting refreshing process)',
      () async {
    const refreshedTokenPair = TokenPair(
      accessToken: '<refreshed_access_token>',
      refreshToken: '<refreshed_refresh_token>',
    );

    final TokenRefresher tokenRefresher = (tokenPair) {
      return Observable<TokenPair>.fromFuture(Future.delayed(
        const Duration(milliseconds: 200),
        () => refreshedTokenPair,
      ));
    };

    const initialTokenPair = TokenPair(
      accessToken: '<access_token>',
      refreshToken: '<refresh_token>',
    );

    final tokenManager = TokenManager(
      tokenRefresher: tokenRefresher,
      tokenPair: initialTokenPair,
    );

    tokenManager.refreshTokens().listen((_) => null);

    final tokenPair = await tokenManager.getTokens().first;

    expect(tokenPair.accessToken, refreshedTokenPair.accessToken);
    expect(tokenPair.refreshToken, refreshedTokenPair.refreshToken);
  });

  test('Should repeat token refreshing on fail', () async {
    const refreshedTokenPair = TokenPair(
      accessToken: '<refreshed_access_token>',
      refreshToken: '<refreshed_refresh_token>',
    );

    var counter = 0;

    final tokenRefresher = (tokenPair) {
      return Observable<TokenPair>.fromFuture(Future.delayed(
        const Duration(milliseconds: 200),
        () {
          if (counter < 1) {
            counter++;
            throw 'Error on refreshing tokens';
          }

          return refreshedTokenPair;
        },
      ));
    };

    final tokenManager = TokenManager(
      tokenRefresher: tokenRefresher,
    );

    tokenManager.refreshTokens().listen((_) => null);

    final tokenPair = await tokenManager.getTokens().first;

    expect(tokenPair.accessToken, refreshedTokenPair.accessToken);
    expect(tokenPair.refreshToken, refreshedTokenPair.refreshToken);
  });

  test('Should return same tokens on multiple refreshing requests', () async {
    final randomToken = () => Random().nextInt(1000).toString();

    final tokenRefresher = (TokenPair tokenPair) {
      return Observable<TokenPair>.fromFuture(Future.delayed(
        const Duration(milliseconds: 200),
        () {
          return TokenPair(
            accessToken: randomToken(),
            refreshToken: randomToken(),
          );
        },
      ));
    };

    final tokenManager = TokenManager(
      tokenRefresher: tokenRefresher,
    );

    tokenManager.refreshTokens().listen((_) => null);
    final request1 = tokenManager.getTokens().take(1);

    tokenManager.refreshTokens().listen((_) => null);
    final request2 = tokenManager.getTokens().take(1);

    tokenManager.refreshTokens().listen((_) => null);
    final request3 = tokenManager.getTokens().take(1);

    final isTokensPairsTheSame = await Observable.combineLatest(
      [request1, request2, request3],
      (tokenPairs) => tokenPairs,
    ).map((tokenGroups) {
      final tokenPair1 = tokenGroups[0];
      final tokenPair2 = tokenGroups[1];
      final tokenPair3 = tokenGroups[2];

      final isAccessTokensEquals =
          (tokenPair1.accessToken == tokenPair2.accessToken) &&
              (tokenPair2.accessToken == tokenPair3.accessToken);

      final isRefreshTokenEquals =
          (tokenPair1.refreshToken == tokenPair2.refreshToken) &&
              (tokenPair2.refreshToken == tokenPair3.refreshToken);

      return isAccessTokensEquals && isRefreshTokenEquals;
    }).first;

    assert(isTokensPairsTheSame, true);
  });

  test('Should always return new tokens from server when refreshing started',
      () async {
    const refreshedTokenPair = TokenPair(
      accessToken: '<refreshed_access_token>',
      refreshToken: '<refreshed_refresh_token>',
    );

    final TokenRefresher tokenRefresher = (tokenPair) {
      return Observable<TokenPair>.fromFuture(Future.delayed(
        const Duration(milliseconds: 200),
        () => refreshedTokenPair,
      ));
    };

    const updatedTokenPair = TokenPair(
      accessToken: '<updated_access_token>',
      refreshToken: '<updated_refresh_token>',
    );

    final tokenManager = TokenManager(tokenRefresher: tokenRefresher);

    // Run refresh tokens request
    tokenManager.refreshTokens().listen((_) => null);

    // Update token pair manually
    tokenManager.updateTokens(updatedTokenPair);

    final resultTokenPair = await tokenManager.getTokens().first;
    expect(resultTokenPair, refreshedTokenPair);
  });

  test('Should throw Token Refreshing Error if server unavailable', () async {
    const error = 'Server unavailable';
    final tokenRefresher = (tokenPair) {
      return Observable<TokenPair>.fromFuture(Future.error(error));
    };

    final tokenManager = TokenManager(tokenRefresher: tokenRefresher);

    dynamic resultError;
    try {
      await tokenManager.refreshTokens().first;
    } catch (ex) {
      resultError = ex;
    }

    expect(resultError, error);
  });
}
