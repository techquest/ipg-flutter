import 'package:flutter_test/flutter_test.dart';
import 'package:isw_webpay/isw_webpay.dart';

void main() {
  group('WebpayClient', () {
    test('should generate unique transaction references', () {
      final client = WebpayClient(
        merchantCode: 'TEST123',
        payItemId: 'TEST456',
        redirectUrl: 'https://example.com/callback',
      );

      final txnRef1 = client.generateTxnRef();
      final txnRef2 = client.generateTxnRef();

      expect(txnRef1, isNotEmpty);
      expect(txnRef2, isNotEmpty);
      expect(txnRef1, isNot(equals(txnRef2)));
      expect(txnRef1, startsWith('txn_'));
    });

    test('should use test URL in test mode', () {
      final client = WebpayClient(
        merchantCode: 'TEST123',
        payItemId: 'TEST456',
        redirectUrl: 'https://example.com/callback',
        mode: EnvironmentMode.test,
      );

      expect(
        client.baseUrl,
        equals('https://newwebpay.qa.interswitchng.com/collections/w/pay'),
      );
    });

    test('should use live URL in live mode', () {
      final client = WebpayClient(
        merchantCode: 'TEST123',
        payItemId: 'TEST456',
        redirectUrl: 'https://example.com/callback',
        mode: EnvironmentMode.live,
      );

      expect(
        client.baseUrl,
        equals('https://newwebpay.interswitchng.com/collections/w/pay'),
      );
    });

    test('should default to test mode', () {
      final client = WebpayClient(
        merchantCode: 'TEST123',
        payItemId: 'TEST456',
        redirectUrl: 'https://example.com/callback',
      );

      expect(client.mode, equals(EnvironmentMode.test));
    });

    test('should allow custom base URLs', () {
      final customLiveUrl = 'https://custom-live.example.com/pay';
      final customTestUrl = 'https://custom-test.example.com/pay';

      final client = WebpayClient(
        merchantCode: 'TEST123',
        payItemId: 'TEST456',
        redirectUrl: 'https://example.com/callback',
        liveBaseUrl: customLiveUrl,
        testBaseUrl: customTestUrl,
        mode: EnvironmentMode.test,
      );

      expect(client.baseUrl, equals(customTestUrl));
      expect(client.liveBaseUrl, equals(customLiveUrl));
      expect(client.testBaseUrl, equals(customTestUrl));
    });

    test('should generate transaction reference with correct format', () {
      final client = WebpayClient(
        merchantCode: 'TEST123',
        payItemId: 'TEST456',
        redirectUrl: 'https://example.com/callback',
      );

      final txnRef = client.generateTxnRef();
      final parts = txnRef.split('_');

      expect(parts.length, equals(3)); // 'txn', timestamp, random
      expect(parts[0], equals('txn'));
      expect(int.tryParse(parts[1]), isNotNull); // timestamp should be numeric
      expect(int.tryParse(parts[2]), isNotNull); // random should be numeric
    });

    test('should validate transaction reference uniqueness over multiple calls',
        () {
      final client = WebpayClient(
        merchantCode: 'TEST123',
        payItemId: 'TEST456',
        redirectUrl: 'https://example.com/callback',
      );

      final refs = List.generate(100, (_) => client.generateTxnRef());
      final uniqueRefs = refs.toSet();

      expect(uniqueRefs.length, equals(100)); // All should be unique
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
  });
}
