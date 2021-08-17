import 'dart:math';

import 'package:dash_kit_network/dash_kit_network.dart';
import 'package:dash_kit_network/src/token_manager.dart';
import 'package:test/test.dart';

void main() {
  final TokenRefresher emptyTokenRefresher = (tokenPair) => Future.value(null);

  setUp(() async {});

  test('Initial tokens must be empty', () async {
    final tokenManager = TokenManager(
      tokenRefresher: emptyTokenRefresher,
      tokenPair: const TokenPair(accessToken: '', refreshToken: ''),
    );
    final tokenPair = await tokenManager.getTokens();

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

    final tokenPair = await tokenManager.getTokens();

    expect(tokenPair.accessToken, initialTokenPair.accessToken);
    expect(tokenPair.refreshToken, initialTokenPair.refreshToken);
  });

  test('Check updating tokens', () async {
    final tokenManager = TokenManager(
      tokenRefresher: emptyTokenRefresher,
      tokenPair: const TokenPair(accessToken: '', refreshToken: ''),
    );

    const newTokenPair = TokenPair(
      accessToken: '<access_token>',
      refreshToken: '<refresh_token>',
    );

    tokenManager.updateTokens(newTokenPair);

    final tokenPair = await tokenManager.getTokens();

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
      return Future.delayed(
        const Duration(milliseconds: 200),
        () => refreshedTokenPair,
      );
    };

    const initialTokenPair = TokenPair(
      accessToken: '<access_token>',
      refreshToken: '<refresh_token>',
    );

    final tokenManager = TokenManager(
      tokenRefresher: tokenRefresher,
      tokenPair: initialTokenPair,
    );

    await tokenManager.refreshTokens();

    final tokenPair = await tokenManager.getTokens();

    expect(tokenPair.accessToken, refreshedTokenPair.accessToken);
    expect(tokenPair.refreshToken, refreshedTokenPair.refreshToken);
  });

  test('Should repeat token refreshing on fail', () async {
    const refreshedTokenPair = TokenPair(
      accessToken: '<refreshed_access_token>',
      refreshToken: '<refreshed_refresh_token>',
    );

    final TokenRefresher tokenRefresher = (TokenPair tokenPair) async {
      return Future.delayed(
        const Duration(milliseconds: 200),
        () {
          return refreshedTokenPair;
        },
      );
    };

    final tokenManager = TokenManager(
      tokenRefresher: tokenRefresher,
      tokenPair: const TokenPair(accessToken: '', refreshToken: ''),
    );

    await tokenManager.refreshTokens();

    final tokenPair = await tokenManager.getTokens();

    expect(tokenPair.accessToken, refreshedTokenPair.accessToken);
    expect(tokenPair.refreshToken, refreshedTokenPair.refreshToken);
  });

  test('Should return same tokens on multiple refreshing requests', () async {
    final randomToken = () => Random().nextInt(1000).toString();

    final TokenRefresher tokenRefresher = (TokenPair tokenPair) async {
      return Future.delayed(
        const Duration(milliseconds: 200),
        () {
          return TokenPair(
            accessToken: randomToken(),
            refreshToken: randomToken(),
          );
        },
      );
    };

    final tokenManager = TokenManager(
      tokenRefresher: tokenRefresher,
      tokenPair: const TokenPair(accessToken: '', refreshToken: ''),
    );

    final request = () async {
      tokenManager.refreshTokens();
      return tokenManager.getTokens();
    };

    final result = await Future.wait([request(), request(), request()]);

    final tokenPair1 = result[0];
    final tokenPair2 = result[1];
    final tokenPair3 = result[2];

    final isAccessTokensEquals =
        (tokenPair1.accessToken == tokenPair2.accessToken) &&
            (tokenPair2.accessToken == tokenPair3.accessToken);

    final isRefreshTokenEquals =
        (tokenPair1.refreshToken == tokenPair2.refreshToken) &&
            (tokenPair2.refreshToken == tokenPair3.refreshToken);

    final isTokensPairsTheSame = isAccessTokensEquals && isRefreshTokenEquals;

    assert(isTokensPairsTheSame, true);
  });

  test('Should return new tokens on refreshing multiple times', () async {
    final randomToken = () => Random().nextInt(1000).toString();

    final TokenRefresher tokenRefresher = (TokenPair tokenPair) async {
      return Future.delayed(
        const Duration(milliseconds: 200),
        () {
          return TokenPair(
            accessToken: randomToken(),
            refreshToken: randomToken(),
          );
        },
      );
    };

    final tokenManager = TokenManager(
      tokenRefresher: tokenRefresher,
      tokenPair: const TokenPair(accessToken: '', refreshToken: ''),
    );

    tokenManager.refreshTokens();
    final tokenPair1 = await tokenManager.getTokens();

    tokenManager.refreshTokens();
    final tokenPair2 = await tokenManager.getTokens();

    final areTokensDifferent =
        tokenPair1.refreshToken != tokenPair2.refreshToken &&
            tokenPair1.accessToken != tokenPair2.accessToken;

    assert(areTokensDifferent, true);
  });

  test('Should always return new tokens from server when refreshing started',
      () async {
    const refreshedTokenPair = TokenPair(
      accessToken: '<refreshed_access_token>',
      refreshToken: '<refreshed_refresh_token>',
    );

    final TokenRefresher tokenRefresher = (TokenPair tokenPair) {
      return Future.delayed(
        const Duration(milliseconds: 200),
        () => refreshedTokenPair,
      );
    };

    const updatedTokenPair = TokenPair(
      accessToken: '<updated_access_token>',
      refreshToken: '<updated_refresh_token>',
    );

    final tokenManager = TokenManager(
      tokenRefresher: tokenRefresher,
      tokenPair: const TokenPair(accessToken: '', refreshToken: ''),
    );

    // Run refresh tokens request
    tokenManager.refreshTokens();

    // Update token pair manually
    tokenManager.updateTokens(updatedTokenPair);

    final resultTokenPair = await tokenManager.getTokens();
    expect(resultTokenPair, refreshedTokenPair);
  });

  test('Should throw Token Refreshing Error if server unavailable', () async {
    const error = 'Server unavailable';
    final TokenRefresher tokenRefresher = (TokenPair tokenPair) async {
      return Future.error(error);
    };

    final tokenManager = TokenManager(
      tokenRefresher: tokenRefresher,
      tokenPair: const TokenPair(accessToken: '', refreshToken: ''),
    );

    dynamic resultError;
    try {
      await tokenManager.refreshTokens();
    } catch (ex) {
      resultError = ex;
    }

    expect(resultError, error);
  });
}
