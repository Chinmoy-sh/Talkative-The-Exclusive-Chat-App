import 'package:flutter/material.dart';

class CallScreen extends StatelessWidget {
  final String callId;
  final bool isIncoming;
  final bool isVideoCall;
  final String callerName;
  final String callerImage;

  const CallScreen({
    super.key,
    this.callId = '',
    this.isIncoming = false,
    this.isVideoCall = false,
    this.callerName = 'Unknown',
    this.callerImage = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isVideoCall ? 'Video Call' : 'Voice Call')),
      body: const Center(child: Text('Call Screen - Coming Soon')),
    );
  }
}
