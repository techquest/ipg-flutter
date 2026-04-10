import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('App renders payment screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verify the app title is displayed
    expect(find.text('Webpay Payment Demo'), findsOneWidget);

    // Verify the Pay Now button exists
    expect(find.text('Pay Now'), findsOneWidget);

    // Verify order summary section exists
    expect(find.text('Order Summary'), findsOneWidget);

    // Verify customer information section exists
    expect(find.text('Customer Information'), findsOneWidget);

    // Verify test mode notice is shown
    expect(find.text('Test Mode: Using test credentials'), findsOneWidget);
  });
}
