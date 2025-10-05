import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String chatId;
  final String receiverId;
  final String receiverName;
  final String receiverImage;
  final bool isGroupChat;

  const ChatScreen({
    super.key,
    this.chatId = '',
    this.receiverId = '',
    this.receiverName = 'Chat',
    this.receiverImage = '',
    this.isGroupChat = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(receiverName)),
      body: const Center(child: Text('Chat Screen - Coming Soon')),
    );
  }
}
