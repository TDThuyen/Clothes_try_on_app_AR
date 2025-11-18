import 'package:flutter/material.dart';
import 'checkout_payment_screen.dart';
import '../models/checkout/checkout_data.dart';

class CheckoutFirst extends StatelessWidget {
  const CheckoutFirst({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checkout',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const CheckoutScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // FIXED: controllers must be persistent
  final firstNameCtrl = TextEditingController(text: "Pham");
  final lastNameCtrl = TextEditingController();
  final countryCtrl = TextEditingController();
  final streetCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final zipCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final couponCtrl = TextEditingController();

  String selectedShippingMethod = "free";
  bool copyAddressFromShipping = false;
  String selectedCountry = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // FIXED: Back button should pop
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Check out',
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Shipping",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              _buildField("First name *", firstNameCtrl),
              const SizedBox(height: 16),

              _buildField("Last name *", lastNameCtrl),
              const SizedBox(height: 16),

              _buildCountryDropdown(),
              const SizedBox(height: 16),

              _buildField("Street name *", streetCtrl),
              const SizedBox(height: 16),

              _buildField("City *", cityCtrl),
              const SizedBox(height: 16),

              _buildField("State / Province", stateCtrl),
              const SizedBox(height: 16),

              _buildField("Zip-code *", zipCtrl),
              const SizedBox(height: 16),

              _buildField("Phone number *", phoneCtrl),
              const SizedBox(height: 30),

              const Text(
                "Shipping method",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _shippingOption(
                "free",
                "Free",
                "Delivery to home",
                "",
                const Color(0xFF4A9B8E),
              ),
              const SizedBox(height: 12),

              _shippingOption(
                "standard",
                "\$ 9.90",
                "Delivery to home",
                "Delivery time is 3-5 business days",
                null,
              ),
              const SizedBox(height: 12),

              _shippingOption(
                "fast",
                "\$ 9.90",
                "Fast Delivery",
                "Delivery time is 1-2 business days",
                null,
              ),
              const SizedBox(height: 30),

              const Text(
                "Coupon Code",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _buildField("Coupon code", couponCtrl),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C2C2C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),

                  // ⭐ SEND DATA TO PAGE 2
                  onPressed: () {
                    final data = CheckoutData(
                      firstName: firstNameCtrl.text,
                      lastName: lastNameCtrl.text,
                      country: selectedCountry,
                      streetName: streetCtrl.text,
                      city: cityCtrl.text,
                      stateProvince: stateCtrl.text,
                      zipCode: zipCtrl.text,
                      phoneNumber: phoneCtrl.text,
                      shippingMethod: selectedShippingMethod,
                      coupon: couponCtrl.text,
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CheckoutSecond(checkoutData: data),
                      ),
                    );
                  },

                  child: const Text(
                    'Continue to payment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // UI HELPERS ------------------------------------------------------

  Widget _buildField(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const SizedBox(height: 8),

        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountryDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "Country *",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      value: selectedCountry.isEmpty ? null : selectedCountry,
      items: ["United States", "Canada", "United Kingdom", "Vietnam"]
          .map(
            (country) => DropdownMenuItem(value: country, child: Text(country)),
          )
          .toList(),
      onChanged: (value) {
        setState(() => selectedCountry = value ?? "");
      },
    );
  }

  Widget _shippingOption(
    String value,
    String price,
    String title,
    String subtitle,
    Color? color,
  ) {
    bool isSelected = selectedShippingMethod == value;

    return GestureDetector(
      onTap: () => setState(() => selectedShippingMethod = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF4A9B8E) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.circle,
              size: 20,
              color: isSelected ? const Color(0xFF4A9B8E) : Colors.grey,
            ),

            const SizedBox(width: 12),
            if (color != null)
              Icon(Icons.local_shipping_outlined, color: color),

            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$price  $title",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  if (subtitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        subtitle,
                        style: TextStyle(color: Colors.grey[500]),
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
}
