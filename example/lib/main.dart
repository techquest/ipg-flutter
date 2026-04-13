import 'dart:math' show Random;

import 'package:example/payment_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:interswitch_payment_gateway/interswitch_payment_gateway.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IPG Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
      home: const PaymentDemoPage(),
    );
  }
}

class PaymentDemoPage extends StatefulWidget {
  const PaymentDemoPage({super.key});

  @override
  State<PaymentDemoPage> createState() => _PaymentDemoPageState();
}

class _PaymentDemoPageState extends State<PaymentDemoPage> {
  final _formKey = GlobalKey<FormState>();

  // Fixed test credentials
  final String merchantCode = 'MX6072';
  final String payItemId = '9405967';
  final String redirectUrl = 'https://blank.org';

  // Editable fields with controllers
  late TextEditingController _amountController;
  late TextEditingController _currencyController;
  late TextEditingController _txnRefController;
  late TextEditingController _customerNameController;
  late TextEditingController _customerEmailController;
  late TextEditingController _payItemNameController;

  // Environment
  EnvironmentMode _environmentMode = EnvironmentMode.test;

  // Loading state
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '10000');
    _currencyController = TextEditingController(text: '566');
    _txnRefController = TextEditingController(text: _generateTxnRef());
    _customerNameController = TextEditingController(text: 'Sample Customer');
    _customerEmailController = TextEditingController(text: 'example@email.com');
    _payItemNameController = TextEditingController(text: 'Test Item');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _currencyController.dispose();
    _txnRefController.dispose();
    _customerNameController.dispose();
    _customerEmailController.dispose();
    _payItemNameController.dispose();
    super.dispose();
  }

  String _generateTxnRef() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random.secure().nextInt(999999);
    return 'ipg_demo_${timestamp}_$random';
  }

  void _regenerateTxnRef() {
    setState(() {
      _txnRefController.text = _generateTxnRef();
    });
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final webpay = WebpayClient(
      merchantCode: merchantCode,
      payItemId: payItemId,
      redirectUrl: redirectUrl,
      mode: _environmentMode,
      custName: _customerNameController.text,
      custEmail: _customerEmailController.text,
      payItemName: _payItemNameController.text,
    );

    try {
      final result = await webpay.checkout(
        context: context,
        amount: int.parse(_amountController.text),
        currency: int.parse(_currencyController.text),
        txnRef: _txnRefController.text,
        timeout: const Duration(minutes: 5),
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment cancelled by user'),
            backgroundColor: Colors.red,
          ),
        );
        // Regenerate txnRef for next attempt
        _regenerateTxnRef();
        return;
      }

      // Navigate to result screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentResultScreen(
            result: result,
            amount: int.parse(_amountController.text),
            itemName: _payItemNameController.text,
          ),
        ),
      );

      // Regenerate txnRef for next payment
      _regenerateTxnRef();
    } on WebpayException catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Payment Error'),
          content: Text(e.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      // Regenerate txnRef for next attempt
      _regenerateTxnRef();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interswitch Payment Gateway Demo'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Merchant Configuration Section
            _buildSectionHeader('Merchant Configuration'),
            _buildReadOnlyField('MerchantCode', merchantCode),
            const SizedBox(height: 12),
            _buildReadOnlyField('Pay Item ID', payItemId),
            const SizedBox(height: 12),
            _buildReadOnlyField('Redirect URL', redirectUrl),
            const SizedBox(height: 12),

            // Environment Mode Dropdown
            _buildLabel('Environment Mode'),
            DropdownButtonFormField<EnvironmentMode>(
              initialValue: _environmentMode,
              decoration: const InputDecoration(),
              items: EnvironmentMode.values.map((mode) {
                return DropdownMenuItem(
                  value: mode,
                  child: Text(mode.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _environmentMode = value);
                }
              },
            ),
            const SizedBox(height: 24),

            // Payment Details Section
            _buildSectionHeader('Payment Details'),
            _buildLabel('Amount (in minor currency)'),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g., 10000 for ₦100.00',
                suffixText: _getFormattedAmount(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Amount is required';
                }
                if (int.tryParse(value) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            _buildLabel('Currency Code'),
            TextFormField(
              controller: _currencyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '566 for NGN'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Currency code is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            _buildLabel('Transaction Reference'),
            TextFormField(
              controller: _txnRefController,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _regenerateTxnRef,
                  tooltip: 'Generate new reference',
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Transaction reference is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            _buildLabel('Pay Item Name'),
            TextFormField(
              controller: _payItemNameController,
              decoration: const InputDecoration(
                hintText: 'Name of item being purchased',
              ),
            ),
            const SizedBox(height: 24),

            // Customer Information Section
            _buildSectionHeader('Customer Information'),
            _buildLabel('Customer Name'),
            TextFormField(
              controller: _customerNameController,
              decoration: const InputDecoration(hintText: 'Customer full name'),
            ),
            const SizedBox(height: 12),

            _buildLabel('Customer Email'),
            TextFormField(
              controller: _customerEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'customer@example.com',
              ),
            ),
            const SizedBox(height: 32),

            // Pay Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Pay',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Test Mode Notice
            if (_environmentMode == EnvironmentMode.test)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade800),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'TEST MODE: No real charges will be made',
                        style: TextStyle(
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _getFormattedAmount() {
    final amount = int.tryParse(_amountController.text);
    if (amount == null) return '';
    return '₦${(amount / 100).toStringAsFixed(2)}';
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}
