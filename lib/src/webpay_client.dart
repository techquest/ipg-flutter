import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/material.dart';

import 'environment_mode.dart';
import 'redirect_webview.dart';

class WebpayClient {
  final String merchantCode;
  final String payItemId;
  final String redirectUrl;
  final EnvironmentMode mode; // 'test' or 'live'

  final String liveBaseUrl;
  final String testBaseUrl;

  WebpayClient({
    required this.merchantCode,
    required this.payItemId,
    required this.redirectUrl,
    this.mode = EnvironmentMode.test,

    this.liveBaseUrl = "https://newwebpay.interswitchng.com/collections/w/pay",
    this.testBaseUrl =
        "https://newwebpay.qa.interswitchng.com/collections/w/pay",
  });

  String get baseUrl =>
      mode == EnvironmentMode.test ? testBaseUrl : liveBaseUrl;

  // Generate a secure, unique transaction reference
  String generateTxnRef() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random.secure().nextInt(999999);
    return 'txn_${timestamp}_$random';
  }

  // Build the minimal HTML that POSTs the form immediately.
  String _buildRedirectHtml({
    required String txnRef,
    required int amount,
    required int currency,
  }) {
    developer.log("Base URL: $baseUrl");
    developer.log("Merchant Code: $merchantCode");
    developer.log("Pay Item ID: $payItemId");
    developer.log("Redirect URL: $redirectUrl");
    developer.log("Transaction Ref: $txnRef");
    developer.log("Amount: $amount");
    developer.log("Currency: $currency");
    developer.log("Loading redirect HTML...");

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
          <form method="post" action="${esc(baseUrl)}">
            <input type="hidden" name="merchant_code" value="${esc(merchantCode)}" />
            <input type="hidden" name="pay_item_id" value="${esc(payItemId)}" />
            <input type="hidden" name="site_redirect_url" value="${esc(redirectUrl)}" />
            <input type="hidden" name="txn_ref" value="${esc(txnRef)}" />
            <input type="hidden" name="amount" value="${esc(amount.toString())}" />
            <input type="hidden" name="currency" value="${esc(currency.toString())}" />
            <input type="hidden" name="display_mode" value="PAGE" />
            <noscript><button type="submit">Continue</button></noscript>
          </form>
        </div>
      </body>
      </html>
      ''';
  }

  /// Opens a full-screen in-app WebView that posts to the payment page and
  /// intercepts the redirect back to [redirectUrl]. Returns the redirect data.
  ///
  /// [amount] should be in minor currency units (kobo for Nigerian Naira).
  /// For example, to charge ₦100.00, pass 10000.
  ///
  /// [currency] defaults to 566 (Nigerian Naira ISO 4217 code).
  ///
  /// [txnRef] is optional. If not provided, a unique transaction reference
  /// will be automatically generated.
  ///
  /// Returns a [Map] containing the payment response parameters, or null if
  /// the user cancels the payment.
  Future<Map<String, dynamic>?> checkout({
    required BuildContext context,
    required int amount,
    int currency = 566,
    String? txnRef,
  }) async {
    final ref = txnRef ?? generateTxnRef();
    developer.log("Redirecting with txnRef: $ref");

    final html = _buildRedirectHtml(
      txnRef: ref,
      amount: amount,
      currency: currency,
    );
    return Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            RedirectWebViewPage(html: html, siteRedirectUrl: redirectUrl),
      ),
    );
  }
}
