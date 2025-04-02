class WebViewException implements Exception {
  final String message;
  WebViewException(this.message);

  @override
  String toString() {
    return 'WebViewException: $message';
  }
}
