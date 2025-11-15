import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../apis/auth.dart';

class VerificationScreen extends StatefulWidget {
  final String email;
  final int userId;

  const VerificationScreen({
    super.key,
    required this.email,
    required this.userId,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final int _otpLength = 6;
  bool _isOtpComplete = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _otpLength; i++) {
      _controllers[i].addListener(_onOtpChanged);
    }
  }

  void _onOtpChanged() {
    final otp = _controllers.map((c) => c.text).join();
    final complete = otp.length == _otpLength;
    if (complete != _isOtpComplete) {
      setState(() {
        _isOtpComplete = complete;
      });
    }
  }

  void _submitOtp() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length != _otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final authService = AuthService(baseUrl: 'http://10.0.2.2:3000/');
      await authService.verifyOtp(
        userId: widget.userId,
        otp: otp,
      );

      if (!mounted) return;
      Navigator.of(context).pop();

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification successful! Please login.')),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();

      final message = (e as dynamic).message?.toString() ?? 'Unexpected error';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          duration: const Duration(seconds: 3),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Verification'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Enter the 6-digit code sent to your email:\n${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),

              // OTP fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 40,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          if (index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else {
                            _focusNodes[index].unfocus();
                          }
                        } else if (value.isEmpty) {
                          if (index > 0) {
                            _focusNodes[index - 1].requestFocus();
                            _controllers[index - 1].selection = TextSelection.fromPosition(
                              TextPosition(offset: _controllers[index - 1].text.length),
                            );
                          }
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isOtpComplete ? _submitOtp : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isOtpComplete ? Colors.green : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Verify', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
