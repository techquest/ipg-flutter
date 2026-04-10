import 'package:flutter/material.dart';

class PaymentResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  final int amount;
  final String itemName;

  const PaymentResultScreen({
    super.key,
    required this.result,
    required this.amount,
    required this.itemName,
  });

  bool get isSuccessful => result['resp'] == '00';

  String get responseDescription =>
      result['desc']?.toString() ??
      "No response description from payment gateway";

  String get transactionRef => result['txnref']?.toString() ?? 'N/A';

  String get formattedAmount {
    final amountValue =
        int.tryParse(result['amount']?.toString() ?? '') ?? amount;
    return '₦${(amountValue / 100).toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              // Status Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: isSuccessful
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccessful ? Icons.check_circle : Icons.cancel,
                  size: 60,
                  color: isSuccessful ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 24),

              // Status Title
              Text(
                isSuccessful ? 'Payment Successful' : 'Payment Failed',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isSuccessful
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 8),

              // Status Description
              Text(
                responseDescription,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Amount
              Text(
                formattedAmount,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                itemName,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),

              // Transaction Details Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildDetailRow('Transaction Ref', transactionRef),
                      const Divider(height: 24),
                      _buildDetailRow(
                        'Status Code',
                        result['resp']?.toString() ?? 'N/A',
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        'Date',
                        DateTime.now().toString().split('.').first,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Done', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
