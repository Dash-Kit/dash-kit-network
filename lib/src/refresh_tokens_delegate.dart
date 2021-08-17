import 'package:dio/dio.dart';
import 'package:dash_kit_network/src/models/token_pair.dart';

/// Delegete that provide a set methods for controlling
/// the process of refreshing authorisation tokens
abstract class RefreshTokensDelegate {
  /// Load from storage already received and saved token pair
  /// for continuing a user session
  Future<TokenPair> loadTokensFromStorage();

  /// Calls when the API returns a new tokens pair.
  /// Save tokens to storage here for continuing user session later.
  Future<void> onTokensUpdated(TokenPair tokenPair);

  /// This method will be called when API cannot update token pair
  /// because of the refresh token is expired.
  /// User should be redirected to sign-in screen in that case
  void onTokensRefreshingFailed();

  /// Calls to determine if the request failed
  /// because the access token expired or not.
  /// If so, the refresh token process will be started
  bool isAccessTokenExpired(DioError error);

  /// Calls to determine if the request failed
  /// because the refresh token expired or not.
  /// If so, `onTokensRefreshingFailed` will be called
  bool isRefreshTokenExpired(DioError error);

  /// Calls to attach access token to authorised request
  Options appendAccessTokenToRequest(
    Options options,
    TokenPair? tokenPair,
  );

  /// Request for tokens refreshing
  Future<TokenPair> refreshTokens(Dio dio, TokenPair tokenPair);
}
