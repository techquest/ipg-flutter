import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';
import 'package:example/payment_result_screen.dart';

void main() {
  // Helper to pump the demo page with a tall viewport so the entire form
  // is rendered inside the ListView without needing to scroll.
  Future<void> pumpDemo(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
  }

  group('PaymentDemoPage', () {
    testWidgets('renders with expected UI elements', (
      WidgetTester tester,
    ) async {
      await pumpDemo(tester);

      expect(find.text('Interswitch Payment Gateway Demo'), findsOneWidget);
      expect(find.text('Merchant Configuration'), findsOneWidget);
      expect(find.text('Payment Details'), findsOneWidget);
      expect(find.text('Customer Information'), findsOneWidget);
      expect(find.text('Pay'), findsOneWidget);
      expect(
        find.text('TEST MODE: No real charges will be made'),
        findsOneWidget,
      );
    });

    testWidgets('shows validation errors when required fields are empty', (
      WidgetTester tester,
    ) async {
      await pumpDemo(tester);

      // The first six TextFormFields are the required ones, in order:
      // Merchant Code, Pay Item ID, Redirect URL, Amount, Currency,
      // Transaction Reference.
      final fields = find.byType(TextFormField);
      for (var i = 0; i < 6; i++) {
        await tester.enterText(fields.at(i), '');
      }

      await tester.tap(find.text('Pay'));
      await tester.pump();

      expect(find.text('Merchant code is required'), findsOneWidget);
      expect(find.text('Pay item ID is required'), findsOneWidget);
      expect(find.text('Redirect URL is required'), findsOneWidget);
      expect(find.text('Amount is required'), findsOneWidget);
      expect(find.text('Currency code is required'), findsOneWidget);
      expect(find.text('Transaction reference is required'), findsOneWidget);
    });
  });

  group('PaymentResultScreen', () {
    testWidgets('renders a successful result', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PaymentResultScreen(
            result: const {
              'resp': '00',
              'desc': 'Approved',
              'txnref': 'TXN123',
              'amount': '10000',
            },
            amount: 10000,
            itemName: 'Test Item',
          ),
        ),
      );

      expect(find.text('Payment Successful'), findsOneWidget);
      expect(find.text('Approved'), findsOneWidget);
      expect(find.text('₦100.00'), findsOneWidget);
      expect(find.text('Test Item'), findsOneWidget);
      expect(find.text('TXN123'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('renders a failed result', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PaymentResultScreen(
            result: const {
              'resp': 'Z0',
              'desc': 'Declined',
              'txnref': 'TXN456',
              'amount': '5000',
            },
            amount: 5000,
            itemName: 'Failed Item',
          ),
        ),
      );

      expect(find.text('Payment Failed'), findsOneWidget);
      expect(find.text('Declined'), findsOneWidget);
      expect(find.text('₦50.00'), findsOneWidget);
      expect(find.text('Failed Item'), findsOneWidget);
      expect(find.text('TXN456'), findsOneWidget);
    });
  });
}
