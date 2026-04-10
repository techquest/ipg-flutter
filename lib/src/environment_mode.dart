/// The environment mode for Interswitch Web Checkout.
///
/// Use [test] for development and testing with Interswitch's sandbox.
/// Use [live] for production payments with real transactions.
enum EnvironmentMode {
  /// Sandbox environment for testing.
  /// Uses test credentials and no real money is charged.
  test,

  /// Production environment for live payments.
  /// Real transactions will be processed.
  live,
}
