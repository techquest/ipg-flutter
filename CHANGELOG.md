## 0.0.1

- Initial release of `interswitch_payment_gateway` - Interswitch Payment Gateway SDK for Flutter
- `WebpayClient` for managing payment configuration
- `checkout()` method for processing payments via WebView
- `WebpayException` for handling technical errors (network, timeout, WebView errors)
- Support for test and live environments via `EnvironmentMode`
- Payment response returned as `Map<String, dynamic>` with `resp`, `desc`, `txnref`, `amount`
- Optional customer information support (`custName`, `custEmail`, `custId`, `custMobileNo`, `payItemName`)
- Optional timeout support for payment flow
