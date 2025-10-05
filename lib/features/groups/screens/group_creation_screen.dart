import 'package:flutter/material.dart';

class GroupCreationScreen extends StatelessWidget {
  final List<String> selectedContacts;

  const GroupCreationScreen({super.key, this.selectedContacts = const []});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Group')),
      body: const Center(child: Text('Group Creation Screen - Coming Soon')),
    );
  }
}
