import 'package:flutter/material.dart';

class GroupInfoScreen extends StatelessWidget {
  final String groupId;

  const GroupInfoScreen({super.key, this.groupId = ''});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group Info')),
      body: const Center(child: Text('Group Info Screen - Coming Soon')),
    );
  }
}
