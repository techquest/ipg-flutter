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
    final webpay = WebpayClient(
      merchantCode: 'MX6072',
      payItemId: '9405967',
      redirectUrl: 'https://google.com/',
      mode: EnvironmentMode.test,
    );

    return Scaffold(
      appBar: AppBar(title: Text('Webpay Payment')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            log("Checkout button clicked ...");
            final result = await webpay.checkout(
              context: context,
              amount: 10000,
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
