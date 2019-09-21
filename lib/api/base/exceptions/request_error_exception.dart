class RequestErrorException implements Exception {
  @override
  String toString() {
    return "Network request error has occurred";
  }
}
