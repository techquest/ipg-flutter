## 0.0.2

### Breaking

- `WebpayClient.mode` is now required. It previously defaulted to
  `EnvironmentMode.test`, so existing callers must pass `mode` explicitly.

### Changed

- Test mode now targets the Interswitch sandbox environment
  (`newwebpay-sandbox.interswitchng.com`) instead of the QA environment. Live
  mode continues to target production (`newwebpay.interswitchng.com`).
- Minimum supported Dart SDK raised to `3.13.0` and Flutter to `3.38.0`.

### Added

- `WebpayClient.baseUrl` exposes the resolved Web Checkout endpoint, so
  integrations can log or assert which environment they are hitting.

## 0.0.1

- Initial release of the Interswitch Payment Gateway Flutter SDK
