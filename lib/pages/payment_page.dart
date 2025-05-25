import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  String cardNumber = '';
  String pin = '';
  String amount = '';

  void _submitPayment() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Payment Successful!'),
          content: Text('Amount of $amount Toman from card $cardNumber was paid.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 24),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Credit Card Number',
                  prefixIcon: Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                maxLength: 16,
                validator: (value) =>
                value == null || value.length != 16 ? 'Card number must be 16 digits' : null,
                onSaved: (value) => cardNumber = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'PIN (4 digits)',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                maxLength: 4,
                keyboardType: TextInputType.number,
                validator: (value) =>
                value == null || value.length != 4 ? 'PIN must be 4 digits' : null,
                onSaved: (value) => pin = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Payment Amount (Toman)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter the amount' : null,
                onSaved: (value) => amount = value!,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.payment),
                label: const Text('Pay'),
                onPressed: _submitPayment,
              ),
            ],
          ),
        ),
      ),
    );
  }
}