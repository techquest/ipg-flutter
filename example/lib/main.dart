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
      appBar: AppBar(
        title: const Text('Webpay Payment Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Payment Summary Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.shopping_bag,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Order Summary',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildInfoRow('Item', 'Premium Subscription'),
                    const SizedBox(height: 12),
                    _buildInfoRow('Amount', '₦100.00'),
                    const SizedBox(height: 12),
                    _buildInfoRow('Payment Method', 'Interswitch Webpay'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Customer Information Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Customer Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildInfoRow('Name', 'John Doe'),
                    const SizedBox(height: 12),
                    _buildInfoRow('Email', 'john.doe@example.com'),
                    const SizedBox(height: 12),
                    _buildInfoRow('Customer ID', 'CUST12345'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Pay Now Button
            ElevatedButton.icon(
              onPressed: () async {
                log("Checkout button clicked ...");
                // Amount is in minor currency units (kobo for NGN)
                // 10000 kobo = ₦100.00
                final result = await webpay.checkout(
                  context: context,
                  amount: 10000, // ₦100.00
                  // Optional: Override customer info for this transaction
                  // custName: 'Jane Smith',
                  // custEmail: 'jane.smith@example.com',
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
              icon: const Icon(Icons.payment),
              label: const Text('Pay Now', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Test Mode Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade700),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber.shade900),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Test Mode: Using test credentials',
                      style: TextStyle(
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }
}
