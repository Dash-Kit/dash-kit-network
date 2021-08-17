/// Set of configurations values for communication with API
class ApiEnvironment {
  const ApiEnvironment({
    required this.baseUrl,
    this.validateRequestsByDefault = true,
    this.isRequestsAuthorisedByDefault = false,
  });

  /// Base URL of the API
  final String baseUrl;

  /// Indicates should request with status code different from 2xx
  /// treated as failed by default.
  /// Set it to false if you need to process failed requests responses.
  final bool validateRequestsByDefault;

  /// Indicates should API client add authorisation header to
  /// requests by default.
  final bool isRequestsAuthorisedByDefault;
}
