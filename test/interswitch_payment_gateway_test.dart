import 'package:flutter_test/flutter_test.dart';
import 'package:interswitch_payment_gateway/interswitch_payment_gateway.dart';

void main() {
  group('WebpayClient', () {
    test('should default to test mode', () {
      final client = WebpayClient(
        merchantCode: 'TEST123',
        payItemId: 'TEST456',
        redirectUrl: 'https://example.com/callback',
      );

      expect(client.mode, equals(EnvironmentMode.test));
    });

    test('should store merchant configuration correctly', () {
      final client = WebpayClient(
        merchantCode: 'MX6072',
        payItemId: '9405967',
        redirectUrl: 'https://myapp.com/payment-callback',
      );

      expect(client.merchantCode, equals('MX6072'));
      expect(client.payItemId, equals('9405967'));
      expect(client.redirectUrl, equals('https://myapp.com/payment-callback'));
    });

    test('should store optional customer information', () {
      final client = WebpayClient(
        merchantCode: 'TEST123',
        payItemId: 'TEST456',
        redirectUrl: 'https://example.com/callback',
        custName: 'John Doe',
        custEmail: 'john@example.com',
        custId: 'CUST001',
        custMobileNo: '08012345678',
        payItemName: 'Test Item',
      );

      expect(client.custName, equals('John Doe'));
      expect(client.custEmail, equals('john@example.com'));
      expect(client.custId, equals('CUST001'));
      expect(client.custMobileNo, equals('08012345678'));
      expect(client.payItemName, equals('Test Item'));
    });

    test('should have null optional fields by default', () {
      final client = WebpayClient(
        merchantCode: 'TEST123',
        payItemId: 'TEST456',
        redirectUrl: 'https://example.com/callback',
      );

      expect(client.custName, isNull);
      expect(client.custEmail, isNull);
      expect(client.custId, isNull);
      expect(client.custMobileNo, isNull);
      expect(client.payItemName, isNull);
    });

    test('should accept live mode', () {
      final client = WebpayClient(
        merchantCode: 'TEST123',
        payItemId: 'TEST456',
        redirectUrl: 'https://example.com/callback',
        mode: EnvironmentMode.live,
      );

      expect(client.mode, equals(EnvironmentMode.live));
    });
  });

  group('WebpayException', () {
    test('should format message correctly with error code', () {
      const exception = WebpayException(
        errorCode: -2,
        message: 'Network error',
      );

      expect(
        exception.toString(),
        equals('WebpayException: Network error (code: -2)'),
      );
    });

    test('should format message correctly without error code', () {
      const exception = WebpayException(
        message: 'Unknown error',
      );

      expect(
        exception.toString(),
        equals('WebpayException: Unknown error'),
      );
    });
  });

  group('EnvironmentMode', () {
    test('should have test and live values', () {
      expect(EnvironmentMode.values, contains(EnvironmentMode.test));
      expect(EnvironmentMode.values, contains(EnvironmentMode.live));
    });
  });
}
