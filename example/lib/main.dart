import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:isw_webpay/isw_webpay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const WebPay(),
    );
  }
}

class WebPay extends StatelessWidget {
  const WebPay({super.key});

  @override
  Widget build(BuildContext context) {
    // NOTE: These are TEST credentials for demonstration purposes only.
    // Replace with your actual Interswitch merchant credentials in production.
    // Visit https://www.interswitchgroup.com/ to obtain your credentials.
    final webpay = WebpayClient(
      merchantCode: 'MX6072', // Test merchant code
      payItemId: '9405967', // Test pay item ID
      redirectUrl: 'https://google.com/', // Your app's callback URL
      mode: EnvironmentMode.test, // Use EnvironmentMode.live for production
      // Optional: Set default customer information
      custName: 'John Doe',
      custEmail: 'john.doe@example.com',
      custId: 'CUST12345',
      payItemName: 'Premium Subscription',
    );

    return Scaffold(
      appBar: AppBar(title: Text('Webpay Payment')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            log("Checkout button clicked ...");
            // Amount is in minor currency units (kobo for NGN)
            // 10000 kobo = ₦100.00
            final result = await webpay.checkout(
              context: context,
              amount: 10000, // ₦100.00
              // Optional: Override customer info for this transaction
              // custName: 'John Doe',
              // custEmail: 'john.doe@example.com',
            );
            log("Payment redirect result: $result");

            if (!context.mounted) return;
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Payment Result'),
                content: Text(result?.toString() ?? 'No result'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
          child: Text('Pay Now'),
        ),
      ),
    );
  }
}
