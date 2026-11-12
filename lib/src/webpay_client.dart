import 'package:material_ui/material_ui.dart';

import 'constants.dart';
import 'environment_mode.dart';
import 'redirect_webview.dart';
import 'webpay_exception.dart';

/// Client for integrating Interswitch Web Checkout in Flutter applications.
///
/// Supports card payments, bank transfers, USSD, QR codes, and wallet payments
/// through Interswitch's payment gateway.
///
/// Example:
/// ```dart
/// final webpay = WebpayClient(
///   merchantCode: 'YOUR_MERCHANT_CODE',
///   payItemId: 'YOUR_PAY_ITEM_ID',
///   redirectUrl: 'https://your-domain.com/callback',
///   mode: EnvironmentMode.live,
/// );
///
/// final result = await webpay.checkout(
///   context: context,
///   amount: 10000, // ₦100.00 in kobo
///   txnRef: 'unique_transaction_ref',
/// );
///
/// if (result != null && result['resp'] == '00') {
///   // Payment successful
/// }
/// ```
class WebpayClient {
  /// Your Interswitch merchant code.
  final String merchantCode;

  /// Your Interswitch pay item ID.
  final String payItemId;

  /// URL where Interswitch redirects after payment.
  /// The payment response will be appended as query parameters.
  final String redirectUrl;

  /// Environment mode (test or live).
  final EnvironmentMode mode;

  /// Optional default customer name.
  final String? custName;

  /// Optional default customer email.
  final String? custEmail;

  /// Optional default customer ID.
  final String? custId;

  /// Optional default customer mobile number.
  final String? custMobileNo;

  /// Optional default payment item name.
  final String? payItemName;

  WebpayClient({
    required this.merchantCode,
    required this.payItemId,
    required this.redirectUrl,
    required this.mode,
    this.custName,
    this.custEmail,
    this.custId,
    this.custMobileNo,
    this.payItemName,
  });

  static const String _liveBaseUrl = kWebPayHostProd;
  static const String _testBaseUrl = kWebPayHostTest;

  String get _baseUrl =>
      mode == EnvironmentMode.test ? _testBaseUrl : _liveBaseUrl;

  /// The Web Checkout endpoint this client will submit to.
  ///
  /// Resolves to the Interswitch sandbox host when [mode] is
  /// [EnvironmentMode.test], and the production host otherwise. Useful for
  /// logging and for verifying which environment an integration is hitting.
  String get baseUrl => _baseUrl;

  String _buildRedirectHtml({
    required String txnRef,
    required int amount,
    required int currency,
    String? custName,
    String? custEmail,
    String? custId,
    String? custMobileNo,
    String? payItemName,
    // List<String>? renderedMethods,
  }) {
    // TODO: Add support for renderedMethods
    // final renderedMethodsValue =
    //     (renderedMethods != null && renderedMethods.isNotEmpty
    //     ? jsonEncode(renderedMethods)
    //     : null);
    String esc(String v) => v
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');

    return '''
      <!doctype html>
      <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Redirect Checkout</title>
        <style>
          body { font-family: -apple-system, Roboto, Helvetica, Arial, sans-serif; margin: 24px; }
          .box { max-width: 520px; margin: 40px auto; border: 1px solid #ddd; border-radius: 12px; padding: 24px; }
          .muted { color: #666; font-size: 14px; }
          button { padding: 12px 16px; border-radius: 8px; border: 1px solid #ccc; font-weight: 600; }
        </style>
      </head>
      <body onload="document.forms[0].submit()">
        <div class="box">
          <h3>Redirecting to Payment...</h3>
          <p class="muted">Please wait, we're opening the secure payment page.</p>
          <form method="post" action="${esc(_baseUrl)}">
            <input type="hidden" name="merchant_code" value="${esc(merchantCode)}" />
            <input type="hidden" name="pay_item_id" value="${esc(payItemId)}" />
            <input type="hidden" name="site_redirect_url" value="${esc(redirectUrl)}" />
            <input type="hidden" name="txn_ref" value="${esc(txnRef)}" />
            <input type="hidden" name="amount" value="${esc(amount.toString())}" />
            <input type="hidden" name="currency" value="${esc(currency.toString())}" />
            ${custName != null ? '<input type="hidden" name="cust_name" value="${esc(custName)}" />' : ''}
            ${custEmail != null ? '<input type="hidden" name="cust_email" value="${esc(custEmail)}" />' : ''}
            ${custId != null ? '<input type="hidden" name="cust_id" value="${esc(custId)}" />' : ''}
            ${custMobileNo != null ? '<input type="hidden" name="cust_mobile_no" value="${esc(custMobileNo)}" />' : ''}
            ${payItemName != null ? '<input type="hidden" name="pay_item_name" value="${esc(payItemName)}" />' : ''}
            <input type="hidden" name="payment_response_type" value="GET" />
            <noscript><button type="submit">Continue</button></noscript>
          </form>
        </div>
      </body>
      </html>
      ''';
  }

  /// Opens an in-app WebView for Interswitch payment and returns the result.
  ///
  /// [amount] should be in minor currency units (kobo for Nigerian Naira).
  /// For example, to charge ₦100.00, pass 10000.
  ///
  /// [currency] defaults to 566 (Nigerian Naira ISO 4217 code).
  ///
  /// [txnRef] is the unique transaction reference for this payment.
  ///
  /// Optional customer information:
  /// - [custName]: Name of the customer paying
  /// - [custEmail]: Email address of the customer
  /// - [custId]: Unique identifier of the customer on your system
  /// - [custMobileNo]: Customer's mobile number
  /// - [payItemName]: Name of the item being paid for
  ///
  /// Returns a [Map] containing the payment response parameters:
  /// - `resp`: Response code ("00" = success)
  /// - `desc`: Response description
  /// - `txnref`: Transaction reference
  /// - `amount`: Amount in kobo
  ///
  /// Returns null if the user cancels the payment.
  ///
  /// Throws [WebpayException] if a network or WebView error occurs.
  ///
  /// Example:
  /// ```dart
  /// final result = await webpay.checkout(
  ///   context: context,
  ///   amount: 50000, // ₦500.00
  ///   txnRef: 'ORDER_12345',
  ///   custEmail: 'customer@example.com',
  /// );
  ///
  /// if (result == null) {
  ///   print('Payment cancelled');
  /// } else if (result['resp'] == '00') {
  ///   print('Payment successful: ${result['txnref']}');
  /// } else {
  ///   print('Payment failed: ${result['desc']}');
  /// }
  /// ```
  Future<Map<String, dynamic>?> checkout({
    required BuildContext context,
    required int amount,
    required String txnRef,
    int currency = 566,
    String? custName,
    String? custEmail,
    String? custId,
    String? custMobileNo,
    String? payItemName,
    // List<String>? renderedMethods,
  }) async {
    final html = _buildRedirectHtml(
      txnRef: txnRef,
      amount: amount,
      currency: currency,
      custName: custName ?? this.custName,
      custEmail: custEmail ?? this.custEmail,
      custId: custId ?? this.custId,
      custMobileNo: custMobileNo ?? this.custMobileNo,
      payItemName: payItemName ?? this.payItemName,
      // renderedMethods: renderedMethods,
    );

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            RedirectWebViewPage(html: html, siteRedirectUrl: redirectUrl),
      ),
    );

    // Check if result contains an error from the WebView
    if (result != null && result[kWebpayErrorKey] == true) {
      throw WebpayException(
        errorCode: result[kWebpayErrorCodeKey] as int?,
        message:
            result[kWebpayErrorMessageKey] as String? ??
            'An error occurred during payment',
      );
    }

    return result;
  }
}
