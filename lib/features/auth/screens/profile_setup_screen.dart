import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Setup Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: const Center(child: Text('Profile Setup Screen - Coming Soon')),
    );
  }
}
