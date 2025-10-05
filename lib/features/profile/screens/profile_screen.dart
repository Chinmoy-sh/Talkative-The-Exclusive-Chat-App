import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final String? userId;
  final bool isCurrentUser;

  const ProfileScreen({super.key, this.userId, this.isCurrentUser = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile Screen - Coming Soon')),
    );
  }
}
