import 'package:flutter/foundation.dart';

/// Set of configurations values for communication with API
class ApiEnvironment {
  const ApiEnvironment({
    @required this.baseUrl,
    this.validateRequestsByDefaut = true,
    this.isRequestsAuthorisedByDefault = false,
  });

  /// Base URL of the API
  final String baseUrl;

  /// Indicates should request with status code different from 2xx
  /// treated as failed by default.
  /// Set it to false if you need to process failed requests responses.
  final bool validateRequestsByDefaut;

  /// Indicates should API client add authorisation header to
  /// requests by default.
  final bool isRequestsAuthorisedByDefault;
}
