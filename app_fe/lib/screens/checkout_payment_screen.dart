import 'package:flutter/material.dart';

import '../models/checkout/checkout_data.dart';
import '../apis/checkout.dart';
import 'checkout_success_screen.dart';

class CheckoutSecond extends StatelessWidget {
  final CheckoutData checkoutData;

  const CheckoutSecond({Key? key, required this.checkoutData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment',
      home: PaymentScreen(checkoutData: checkoutData),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PaymentScreen extends StatefulWidget {
  final CheckoutData checkoutData;

  const PaymentScreen({Key? key, required this.checkoutData})
      : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPaymentMethod = 'qr';
  bool agreeToTerms = true;
  bool loading = false;
  final String shipping = "Freeship";

  double subtotal = 0.0;

  @override
  void initState() {
    super.initState();
    subtotal = 0.0; // backend handles real subtotal
  }

  // ===========================================================
  // CALL API
  // ===========================================================
  Future<void> placeOrder() async {
    if (loading) return;

    setState(() => loading = true);

    final res = await CheckoutService().placeOrder(
      widget.checkoutData,
      selectedPaymentMethod,
    );

    setState(() => loading = false);

    if (res == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Network error")));
      return;
    }

    if (res.statusCode != 201) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Order failed: ${res.body}")));
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CheckoutThird()),
    );
  }

  // ===========================================================
  // UI
  // ===========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Payment',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                _buildPaymentTab('Cash', Icons.attach_money, 'cash'),
                const SizedBox(width: 12),
                _buildPaymentTab('QR Code', Icons.qr_code, 'qr'),
              ],
            ),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),

            _buildPriceRow("Shipping", shipping),
            const SizedBox(height: 12),

            _buildPriceRow(
              'Subtotal',
              '\$${subtotal.toStringAsFixed(2)}',
              isTotal: true,
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Checkbox(
                  value: agreeToTerms,
                  onChanged: (v) =>
                      setState(() => agreeToTerms = v ?? false),
                ),
                const Expanded(
                  child: Text("I agree to Terms and Conditions"),
                ),
              ],
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: (!agreeToTerms || loading)
                    ? null
                    : () async => await placeOrder(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2C2C),
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Place my order',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // Payment Tab Button
  // ===========================================================
  Widget _buildPaymentTab(String label, IconData icon, String value) {
    final selected = selectedPaymentMethod == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedPaymentMethod = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF2C2C2C) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? Colors.white : Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // Price Row
  // ===========================================================
  Widget _buildPriceRow(String label, String value,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
