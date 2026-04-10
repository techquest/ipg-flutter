# Interswitch Payment Gateway SDK for Flutter

<img width="259" alt="Interswitch" src="https://business.quickteller.com/assets/images/app-logo.svg">

The **Interswitch Payment Gateway (IPG) SDK** for Flutter provides a seamless way to integrate secure payment processing into your mobile applications. Built on top of the robust Interswitch Web Checkout, this SDK simplifies the integration process using a WebView-based redirect flow.

[Official Documentation](https://docs.interswitchgroup.com/docs/web-checkout)

---

## Features

- **Official Integration**: Follows [Interswitch Web Redirect](https://docs.interswitchgroup.com/docs/web-checkout#option-2---web-redirect) standards.
- **Cross-Platform**: Full support for both **iOS** and **Android**.
- **Pure Dart**: No native dependencies - simple integration without platform-specific setup.
- **Multiple Payment Methods**: Card, Bank Transfer, USSD, QR Code, OPay, and Wallets.
- **Built-in Error Handling**: Custom `WebpayException` for network and WebView errors.
- **Timeout Support**: Optional payment timeout to prevent indefinite loading states.

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  ipg_flutter: ^1.0.0
```

OR

Run this command

```sh
flutter pub add ipg_flutter
```

Then run:

```sh
flutter pub get
```

> **Note:** This package requires `webview_flutter` which is included as a dependency. No additional setup needed.

---

## Quick Start

The following example demonstrates a basic payment implementation.

```dart
import 'package:flutter/material.dart';
import 'package:ipg_flutter/ipg_flutter.dart';

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
      // Technical error (network, timeout, etc.)
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

### With Timeout

Set a maximum duration for the payment flow.

```dart
final result = await webpay.checkout(
  context: context,
  amount: 50000,
  txnRef: 'ORDER_123',
  timeout: Duration(minutes: 3), // Cancel after 3 minutes
);
```

## API Reference: WebpayClient Constructor

| Parameter      | Type              | Required | Default | Description                               |
| :------------- | :---------------- | :------: | :------ | :---------------------------------------- |
| `merchantCode` | `String`          | **Yes**  | -       | Your Interswitch Merchant Code.           |
| `payItemId`    | `String`          | **Yes**  | -       | Your Interswitch Pay Item ID.             |
| `redirectUrl`  | `String`          | **Yes**  | -       | URL for capturing payment response.       |
| `mode`         | `EnvironmentMode` | **Yes**  | `test`  | Environment (`test` or `live`).           |
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
| `timeout`      | `Duration?`    |    No    | -       | Maximum duration before timeout error.                   |

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

### Common Response Codes

| Code | Description            |
| :--- | :--------------------- |
| `00` | Approved / Successful  |
| `Z1` | Transaction not found  |
| `Z5` | Transaction pending    |
| `Z6` | Transaction processing |

For a complete list, see [Response Codes](https://docs.interswitchgroup.com/docs/response-codes).

---

## Transaction Verification

> **Important:** Always verify transactions on your backend server using Interswitch's Transaction Status API. The client-side response should not be solely relied upon for confirming payment status.

---

## Test Cards

For testing in sandbox mode, use test cards from Interswitch:
[Test Cards Documentation](https://docs.interswitchgroup.com/docs/test-cards)

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
