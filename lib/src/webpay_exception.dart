/// Exception thrown when a technical error occurs during payment.
///
/// This is thrown for issues like network failures, WebView errors,
/// or other technical problems - not for payment failures from Interswitch.
///
/// Payment failures (e.g., insufficient funds, declined card) are returned
/// in the result map with `resp` != '00'.
class WebpayException implements Exception {
  /// Error code from the WebView or system.
  final int? errorCode;

  /// Human-readable description of the error.
  final String message;

  const WebpayException({
    this.errorCode,
    required this.message,
  });

  @override
  String toString() => 'WebpayException: $message${errorCode != null ? ' (code: $errorCode)' : ''}';
}
