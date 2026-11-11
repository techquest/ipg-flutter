# Interswitch Payment Gateway SDK for Flutter

<img width="259" alt="Interswitch" src="https://business.quickteller.com/assets/images/app-logo.svg">

The **Interswitch Payment Gateway (IPG) SDK** for Flutter provides a seamless way to integrate secure payment processing into your mobile applications. Built on top of the robust Interswitch Web Checkout, this SDK simplifies the integration process using a WebView-based redirect flow.

[Official Documentation](https://docs.interswitchgroup.com/docs/web-checkout)

---

## Features

- **Official Integration**: Follows [Interswitch Web Redirect](https://docs.interswitchgroup.com/docs/web-checkout#option-2---web-redirect) standards.
- **Cross-Platform**: Full support for both **iOS** and **Android**.
- **Pure Dart**: No custom native code — built on the official `webview_flutter` plugins. See [Platform Setup](#platform-setup) for the one permission your Android app needs.
- **Multiple Payment Methods**: Card, Bank Transfer, USSD, QR Code, OPay, and Wallets.
- **Built-in Error Handling**: Custom `WebpayException` for network and WebView errors.

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  interswitch_payment_gateway: ^0.1.0
```

OR

Run this command

```sh
flutter pub add interswitch_payment_gateway
```

Then run:

```sh
flutter pub get
```

> **Note:** This package requires `webview_flutter`, which is included as a dependency. Your app still needs the platform permission shown below.

---

## Platform Setup

The SDK is pure Dart, but it renders Interswitch's checkout in a WebView — so your app must be allowed to make network requests. A freshly created Flutter app is not, by default, on Android.

### Android

Add the `INTERNET` permission to `android/app/src/main/AndroidManifest.xml`, inside the `<manifest>` element:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <!-- ...existing entries... -->
</manifest>
```

Without this, the checkout WebView loads a blank page and no error is surfaced to your code.

### iOS

No additional configuration is required. The checkout is served over HTTPS.

---

## Quick Start

The following example demonstrates a basic payment implementation.

```dart
import 'package:flutter/material.dart';
import 'package:interswitch_payment_gateway/interswitch_payment_gateway.dart';

class PaymentScreen extends StatelessWidget {
  // Replace with your actual Interswitch credentials
  // These are test credentials for demonstration
  final webpay = WebpayClient(
    merchantCode: '<merchant-code>',        // Test merchant code
    payItemId: '<pay-item-id>',          // Test pay item ID
    redirectUrl: '<redirect-url>',
    mode: EnvironmentMode.test,
  );

  Future<void> makePayment(BuildContext context) async {

    try {
      final result = await webpay.checkout(
        context: context,
        amount: 100000, // Amount in Kobo (e.g., 100000 = ₦1,000.00)
        txnRef: '<transaction-reference>',
        custEmail: '<customer-email>',
      );

      if (result == null) {
        // User cancelled the payment
        return;
      }

      if (result['resp'] == '00') {
        // Payment successful - verify on your backend
        print('Success! Ref: ${result['txnref']}');
      } else {
        // Payment failed
        print('Failed: ${result['desc']}');
      }
    } on WebpayException catch (e) {
      // Technical error (network, WebView, etc.)
      print('Error: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => makePayment(context),
      child: const Text('Pay Now'),
    );
  }
}
```

---

## Advanced Usage

### With Customer Information

Pre-fill customer details to streamline the checkout experience.

```dart
final webpay = WebpayClient(
  merchantCode: 'YOUR_MERCHANT_CODE',
  payItemId: 'YOUR_PAY_ITEM_ID',
  redirectUrl: 'https://your-domain.com/callback',
  mode: EnvironmentMode.live,
  // Default customer info (can be overridden per transaction)
  custName: 'John Doe',
  custEmail: 'john@example.com',
  custId: 'CUST_12345',
  payItemName: 'Premium Subscription',
);
```

## API Reference: WebpayClient Constructor

| Parameter      | Type              | Required | Default | Description                               |
| :------------- | :---------------- | :------: | :------ | :---------------------------------------- |
| `merchantCode` | `String`          | **Yes**  | -       | Your Interswitch Merchant Code.           |
| `payItemId`    | `String`          | **Yes**  | -       | Your Interswitch Pay Item ID.             |
| `redirectUrl`  | `String`          | **Yes**  | -       | URL for capturing payment response.       |
| `mode`         | `EnvironmentMode` | **Yes**  | -       | Environment (`test` or `live`).           |
| `custName`     | `String?`         |    No    | -       | Default customer name.                    |
| `custEmail`    | `String?`         |    No    | -       | Default customer email.                   |
| `custId`       | `String?`         |    No    | -       | Default customer ID in your system.       |
| `custMobileNo` | `String?`         |    No    | -       | Default customer mobile number.           |
| `payItemName`  | `String?`         |    No    | -       | Default name of the item being purchased. |

## API Reference: checkout() Method

| Parameter      | Type           | Required | Default | Description                                              |
| :------------- | :------------- | :------: | :------ | :------------------------------------------------------- |
| `context`      | `BuildContext` | **Yes**  | -       | Flutter build context for navigation.                    |
| `amount`       | `int`          | **Yes**  | -       | Transaction amount in **Kobo** (e.g., `100000` = ₦1000). |
| `txnRef`       | `String`       | **Yes**  | -       | Unique transaction reference for the session.            |
| `currency`     | `int`          |    No    | `566`   | ISO 4217 currency code (Default: 566 for NGN).           |
| `custName`     | `String?`      |    No    | -       | Customer name (overrides default).                       |
| `custEmail`    | `String?`      |    No    | -       | Customer email (overrides default).                      |
| `custId`       | `String?`      |    No    | -       | Customer ID (overrides default).                         |
| `custMobileNo` | `String?`      |    No    | -       | Customer mobile number (overrides default).              |
| `payItemName`  | `String?`      |    No    | -       | Item name (overrides default).                           |

---

## Response Handling

### Payment Response Fields

| Field    | Type     | Description                          |
| :------- | :------- | :----------------------------------- |
| `resp`   | `String` | Response code (`"00"` = success).    |
| `desc`   | `String` | Human-readable response description. |
| `txnref` | `String` | Your transaction reference.          |
| `amount` | `String` | Transaction amount in Kobo.          |

### Result Scenarios

| Scenario           | How to Detect            | Action                            |
| :----------------- | :----------------------- | :-------------------------------- |
| Payment successful | `result['resp'] == '00'` | Verify on backend, fulfill order. |
| Payment failed     | `result['resp'] != '00'` | Show `result['desc']` to user.    |
| User cancelled     | `result == null`         | Return to previous screen.        |
| Technical error    | Throws `WebpayException` | Show error message, allow retry.  |

---

## Transaction Verification

> **Important:** Always verify transactions on your backend server using Interswitch's Transaction Status API. The client-side response should not be solely relied upon for confirming payment status.

---

## Test Cards & Transaction Responses

- For testing in sandbox mode, use test cards from Interswitch:
[Test Cards Documentation](https://docs.interswitchgroup.com/docs/test-cards)
- For a complete list of transaction response codes, see [Response Codes](https://docs.interswitchgroup.com/docs/payment-response-codes).

---

## Example

See the [example](example/) directory for a complete working implementation.

---

## Contributing

We welcome contributions! Please submit pull requests or open issues on the [GitHub repository](https://github.com/techquest/ipg-flutter.git).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

_Built for the Flutter community_
