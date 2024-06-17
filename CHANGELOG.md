# CHANGELOG

## [4.2.0]

- Bump dependencies

## [4.1.0]

- Bump dependencies

## [4.0.0]

- Migrated to Dart 3.0
- Replaced Isolate manager with `compute` function for mappers

## [3.8.0]

- Deprecated `onTokensRefreshingFailed()`: This method has been marked as deprecated and will be removed in the next major release. Please resolve errors in `refreshTokens()` using `Future.catchError` instead.
- Deprecated `isRefreshTokenExpired()`: This method has been marked as deprecated and will be removed in the next major release. Please resolve errors in `refreshTokens()` using `Future.catchError` instead.
- Fixed an issue where `onTokensRefreshingFailed()` was only being called when the error was `RefreshTokenExpired`.

## [3.7.0]

- Moved mapper execution to background isolate

## [3.6.0]

- Upgraded Dio to 5.0.0

## [3.5.2]

- Fix parsing issue in ApiClient

## [3.5.1]

- add TimeoutConnectionException

## [3.5.0]

- Update `analysis_options.yaml`
- `analysis_options` now extends from `dash_kit_lints` rules

## [3.4.0]

- Incremented the Flutter SDK version to 3.7.0

## [3.3.4]

- Updated the `flutter_secure_storage` to `^7.0.1`

## [3.3.3]

Added automate deployment via github actions

## [3.3.2]

Fixed an issue with storing tokens on web

## [3.3.1]

Added more details to RequestErrorException

## [3.3.0]

Upgraded dependencies

## [3.2.2]

Fixed an issue with `CancelToken` param

## [3.2.1]

Added optional `CancelToken` param to requests

## [3.2.0]

Fixed empty access token error during concurrent first API calls

## [3.1.1]

Breaking change:
TokenStorage now have the `storage` parameter in constructor to provide settings for each platform

## [3.1.0]

- Implemented web support

## [3.0.3]

- Improved RequestErrorException's toString() method

## [3.0.2]

- Added function which deletes only tokens

## [3.0.1]

- Code formatting

## [3.0.0]

- Release 3.0.0

## [3.0.0-dev.6]

- Fixed issue with the `handleError` method

## [3.0.0-dev.5]

- Added `queryParams` to all types of requests

## [3.0.0-dev.4]

- Added content type

## [3.0.0-dev.3]

- Changed `NetworkConnectionException` signature

## [3.0.0-dev.2]

- Fixed tests

## [3.0.0-dev.1]

- Fixed error handling

## [2.0.6]

- Add content type for requests

## [2.0.4]

- Fixed error handling

## [2.0.3]

- Fixed request auto validate by default

## [2.0.2]

- Added ability to change timeouts in request methods

## [2.0.1]

- Fixed an issue with refreshing tokens

## [2.0.0]

- Migrate to Futures from Streams

## [1.0.2]

- Fixed one more NPE with error delegate

## [1.0.1]

- Fixed NPE with error delegate

## [1.0.0]

- Initial release.
