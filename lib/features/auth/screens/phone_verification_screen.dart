import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PhoneVerificationScreen extends StatelessWidget {
  final String phoneNumber;
  final String verificationId;

  const PhoneVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Phone Verification',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: const Center(
        child: Text('Phone Verification Screen - Coming Soon'),
      ),
    );
  }
}
