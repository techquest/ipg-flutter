## 0.1.0

### Breaking

- `WebpayClient.mode` is now required. It previously defaulted to
  `EnvironmentMode.test`, so existing callers must pass `mode` explicitly.
- Minimum supported SDK raised from Dart `3.10.1` / Flutter `1.17.0` (0.0.1)
  to Dart `3.13.0` / Flutter `3.47.0`. No code changes are required, but apps
  on an older Flutter/Dart can no longer resolve this version — upgrade your
  Flutter SDK (and CI) before upgrading the package.

### Changed

- Test mode now targets the Interswitch sandbox environment
  (`newwebpay-sandbox.interswitchng.com`) instead of the QA environment. Live
  mode continues to target production (`newwebpay.interswitchng.com`).
- Migrated from `package:flutter/material.dart` to the `material_ui` package
  (`^1.11.0`). This is an internal implementation change: the SDK's public API
  is unchanged and consumers do not need to add `material_ui` themselves.

### Added

- `WebpayClient.baseUrl` exposes the resolved Web Checkout endpoint, so
  integrations can log or assert which environment they are hitting.

## 0.0.1

- Initial release of the Interswitch Payment Gateway Flutter SDK
