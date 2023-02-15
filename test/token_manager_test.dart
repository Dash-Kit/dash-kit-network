import 'dart:math';

import 'package:dash_kit_network/dash_kit_network.dart';
import 'package:test/test.dart';

import 'token_manager_test_utils.dart';

void main() {
  final emptyTokenRefresher = (tokenPair) =>
      Future.value(const TokenPair(accessToken: '', refreshToken: ''));

  setUp(() {});

  test('Check initialization with tokens', () async {
    const initialTokenPair = TokenPair(
      accessToken: '<access_token>',
      refreshToken: '<refresh_token>',
    );
    final tokenManager = createTokenManagerWithTokens(
      emptyTokenRefresher,
      initialTokenPair,
    );

    final tokenPair = await tokenManager.getTokens();

    expect(tokenPair.accessToken, initialTokenPair.accessToken);
    expect(tokenPair.refreshToken, initialTokenPair.refreshToken);
  });

  test('Check updating tokens', () async {
    const newTokenPair = TokenPair(
      accessToken: '<access_token>',
      refreshToken: '<refresh_token>',
    );

    final tokenManager = createTokenManagerWithTokens(
      emptyTokenRefresher,
      newTokenPair,
    );

    await tokenManager.updateTokens(newTokenPair);

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

      final tokenRefresher = (tokenPair) {
        return Future.delayed(
          const Duration(milliseconds: 200),
          () => refreshedTokenPair,
        );
      };

      final tokenManager = createTokenManagerWithTokens(
        tokenRefresher,
        refreshedTokenPair,
      );

      await tokenManager.refreshTokens();

      final tokenPair = await tokenManager.getTokens();

      expect(tokenPair.accessToken, refreshedTokenPair.accessToken);
      expect(tokenPair.refreshToken, refreshedTokenPair.refreshToken);
    },
  );

  test('Should repeat token refreshing on fail', () async {
    const refreshedTokenPair = TokenPair(
      accessToken: '<refreshed_access_token>',
      refreshToken: '<refreshed_refresh_token>',
    );

    final tokenRefresher = (tokenPair) async {
      return Future.delayed(
        const Duration(milliseconds: 200),
        () {
          return refreshedTokenPair;
        },
      );
    };

    final tokenManager = createTokenManagerWithTokens(
      tokenRefresher,
      refreshedTokenPair,
    );

    await tokenManager.refreshTokens();

    final tokenPair = await tokenManager.getTokens();

    expect(tokenPair.accessToken, refreshedTokenPair.accessToken);
    expect(tokenPair.refreshToken, refreshedTokenPair.refreshToken);
  });

  test('Should return same tokens on multiple refreshing requests', () async {
    final randomToken = () => Random().nextInt(1000).toString();

    final tokenRefresher = (tokenPair) async {
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

    final tokenManager = createTokenManagerWithTokens(
      tokenRefresher,
      const TokenPair(accessToken: '', refreshToken: ''),
    );

    final request = () async {
      await tokenManager.refreshTokens();

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

    final tokenRefresher = (tokenPair) async {
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

    final tokenManager = createTokenManagerWithTokens(
      tokenRefresher,
      const TokenPair(accessToken: '', refreshToken: ''),
    );

    await tokenManager.refreshTokens();
    final tokenPair1 = await tokenManager.getTokens();

    await tokenManager.refreshTokens();
    final tokenPair2 = await tokenManager.getTokens();

    final areTokensDifferent =
        tokenPair1.refreshToken != tokenPair2.refreshToken &&
            tokenPair1.accessToken != tokenPair2.accessToken;

    assert(areTokensDifferent, true);
  });

  test(
    'Should always return new tokens from server when refreshing started',
    () async {
      const refreshedTokenPair = TokenPair(
        accessToken: '<refreshed_access_token>',
        refreshToken: '<refreshed_refresh_token>',
      );

      final tokenRefresher = (tokenPair) {
        return Future.delayed(
          const Duration(milliseconds: 200),
          () => refreshedTokenPair,
        );
      };

      const updatedTokenPair = TokenPair(
        accessToken: '<updated_access_token>',
        refreshToken: '<updated_refresh_token>',
      );

      final tokenManager = createTokenManagerWithTokens(
        tokenRefresher,
        const TokenPair(accessToken: '', refreshToken: ''),
      );

      // Run refresh tokens request.
      await tokenManager.refreshTokens();

      // Update token pair manually.
      await tokenManager.updateTokens(updatedTokenPair);

      final resultTokenPair = await tokenManager.getTokens();
      expect(resultTokenPair, refreshedTokenPair);
    },
  );

  test('Should throw Token Refreshing Error if server unavailable', () async {
    const error = 'Server unavailable';
    // ignore: omit_local_variable_types
    final Future<TokenPair> Function(TokenPair) tokenRefresher = (tokenPair) {
      return Future.error(error);
    };

    final tokenManager = createTokenManagerWithTokens(
      tokenRefresher,
      const TokenPair(accessToken: '', refreshToken: ''),
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
