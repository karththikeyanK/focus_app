import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_app/provider/route_provider.dart';
import 'package:focus_app/provider/user_provider.dart';
import 'package:focus_app/utill/Appconstant.dart';
import 'package:go_router/go_router.dart';

class OtpVerificationPage extends ConsumerStatefulWidget {


  const OtpVerificationPage({super.key});

  @override
  ConsumerState<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage> {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  int _resendTimer = 5;
  bool _canResend = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _timer?.cancel(); // Cancel any existing timer

    setState(() {
      _resendTimer = 60;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _resendTimer--;
      });

      if (_resendTimer <= 0) {
        timer.cancel();
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _isLoading = true;
    });

    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final result = await ref.read(verifyOtpProvider({'email': AppsConstant.email, 'otp': otp}).future);

      if (result) {
        if (context.mounted) {
          GoRouter.of(context).go(LOGIN);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP verification failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final isSuccess = await ref.read(resendOtpProvider({'email': AppsConstant.email}).future);
      if (!isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to resend OTP')),
        );
        return;
      }

      // Clear all OTP fields
      for (var controller in _otpControllers) {
        controller.clear();
      }

      _startResendTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent successfully')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleOtpInput(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    if (index == 5 && value.isNotEmpty) {
      _verifyOtp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the 6-digit code sent to\n${AppsConstant.email}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 45,
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) => _handleOtpInput(value, index),
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('VERIFY', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: _canResend ? _resendOtp : null,
                child: Text(
                  _canResend
                      ? 'Resend OTP'
                      : 'Resend OTP in $_resendTimer seconds',
                  style: TextStyle(
                    color: _canResend ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}