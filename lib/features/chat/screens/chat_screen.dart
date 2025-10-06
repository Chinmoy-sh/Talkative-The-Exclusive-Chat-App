// ignore_for_file: deprecated_member_use, unused_import

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji;
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/models/chat_model.dart';
import '../../../shared/models/message_model.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final ChatModel chat;
  final String? otherUserId;

  const ChatScreen({super.key, required this.chat, this.otherUserId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonAnimation;

  bool _showEmojiPicker = false;
  final bool _isRecording = false;
  bool _isTyping = false;
  Timer? _typingTimer;

  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  MessageModel? _replyingTo;
  final List<MessageModel> _selectedMessages = [];
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupListeners();
    _requestPermissions();
  }

  void _initializeAnimations() {
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _sendButtonAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _sendButtonController, curve: Curves.easeInOut),
    );
  }

  void _setupListeners() {
    _messageController.addListener(() {
      if (_messageController.text.trim().isNotEmpty) {
        if (!_sendButtonController.isCompleted) {
          _sendButtonController.forward();
        }
        _handleTyping();
      } else {
        if (_sendButtonController.isCompleted) {
          _sendButtonController.reverse();
        }
      }
    });

    _messageFocusNode.addListener(() {
      if (_messageFocusNode.hasFocus && _showEmojiPicker) {
        setState(() => _showEmojiPicker = false);
      }
    });
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.microphone,
      Permission.storage,
      Permission.camera,
    ].request();
  }

  void _handleTyping() {
    if (!_isTyping) {
      setState(() => _isTyping = true);
      // Send typing indicator to other users
      ref.read(chatServiceProvider).sendTypingIndicator(widget.chat.id, true);
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      setState(() => _isTyping = false);
      ref.read(chatServiceProvider).sendTypingIndicator(widget.chat.id, false);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    _sendButtonController.dispose();
    _typingTimer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chat.id));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) => _buildMessagesList(messages),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorState(error),
            ),
          ),
          if (_replyingTo != null) _buildReplyPreview(),
          if (_isSelectionMode) _buildSelectionActions(),
          _buildMessageInput(),
          if (_showEmojiPicker) _buildEmojiPicker(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          if (widget.chat.imageUrl != null)
            Hero(
              tag: 'chat_avatar_${widget.chat.id}',
              child: CircleAvatar(
                radius: 18,
                backgroundImage: CachedNetworkImageProvider(
                  widget.chat.imageUrl!,
                ),
              ),
            )
          else
            Hero(
              tag: 'chat_avatar_${widget.chat.id}',
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryGreenLight,
                child: Text(
                  widget.chat.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.chat.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (_isTyping)
                  Text(
                    'typing...',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else
                  Text(
                    widget.chat.type == ChatType.private
                        ? 'Online'
                        : '${widget.chat.participants.length} members',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (_isSelectionMode)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _exitSelectionMode,
          )
        else ...[
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () => _startVideoCall(),
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () => _startVoiceCall(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view_contact',
                child: Text('View Contact'),
              ),
              const PopupMenuItem(
                value: 'media',
                child: Text('Media, Links, and Docs'),
              ),
              const PopupMenuItem(value: 'search', child: Text('Search')),
              const PopupMenuItem(
                value: 'mute',
                child: Text('Mute Notifications'),
              ),
              const PopupMenuItem(value: 'wallpaper', child: Text('Wallpaper')),
              const PopupMenuItem(
                value: 'clear_chat',
                child: Text('Clear Chat'),
              ),
              const PopupMenuItem(
                value: 'export_chat',
                child: Text('Export Chat'),
              ),
              const PopupMenuItem(value: 'block', child: Text('Block')),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildMessagesList(List<MessageModel> messages) {
    if (messages.isEmpty) {
      return _buildEmptyState();
    }

    return AnimationLimiter(
      child: ListView.builder(
        controller: _scrollController,
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          final isMe =
              message.senderId ==
              ref.read(authServiceProvider).currentUser?.uid;
          final showSenderInfo = _shouldShowSenderInfo(messages, index);
          final showDateSeparator = _shouldShowDateSeparator(messages, index);

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Column(
                  children: [
                    if (showDateSeparator)
                      _buildDateSeparator(message.timestamp),
                    _buildMessageBubble(message, isMe, showSenderInfo),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(
    MessageModel message,
    bool isMe,
    bool showSenderInfo,
  ) {
    final isSelected = _selectedMessages.contains(message);

    return GestureDetector(
      onTap: () => _handleMessageTap(message),
      onLongPress: () => _handleMessageLongPress(message),
      child: Container(
        margin: EdgeInsets.only(
          top: showSenderInfo ? 8 : 2,
          bottom: 2,
          left: isMe ? 50 : 0,
          right: isMe ? 0 : 50,
        ),
        child: Row(
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe && showSenderInfo && widget.chat.type == ChatType.group)
              Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 4),
                child: CircleAvatar(
                  radius: 12,
                  backgroundImage: message.senderProfileUrl != null
                      ? CachedNetworkImageProvider(message.senderProfileUrl!)
                      : null,
                  child: message.senderProfileUrl == null
                      ? Text(
                          message.senderName?[0].toUpperCase() ?? '?',
                          style: const TextStyle(fontSize: 10),
                        )
                      : null,
                ),
              ),
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGreen.withOpacity(0.3)
                      : isMe
                      ? AppColors.sentMessageBubble
                      : Theme.of(context).brightness == Brightness.dark
                      ? AppColors.receivedMessageBubbleDark
                      : AppColors.receivedMessageBubble,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(
                      isMe || !showSenderInfo ? 16 : 4,
                    ),
                    bottomRight: Radius.circular(
                      isMe && showSenderInfo ? 4 : 16,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMe &&
                        widget.chat.type == ChatType.group &&
                        showSenderInfo)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 12,
                          right: 12,
                          top: 8,
                        ),
                        child: Text(
                          message.senderName ?? 'Unknown',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getUserColor(message.senderId),
                          ),
                        ),
                      ),
                    if (message.replyToMessage != null)
                      _buildReplyContent(message.replyToMessage!),
                    _buildMessageContent(message, isMe),
                    _buildMessageFooter(message, isMe),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(MessageModel message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        message.content,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: isMe
              ? Colors.white
              : Theme.of(context).textTheme.bodyLarge?.color,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildMessageFooter(MessageModel message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 8, bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatMessageTime(message.timestamp),
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: isMe ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 4),
            Icon(
              _getMessageStatusIcon(message.status),
              size: 14,
              color: _getMessageStatusColor(message.status),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions,
                      color: AppColors.primaryGreen,
                    ),
                    onPressed: _toggleEmojiPicker,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _messageFocusNode,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      maxLines: 5,
                      minLines: 1,
                      textInputAction: TextInputAction.newline,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.attach_file,
                      color: AppColors.primaryGreen,
                    ),
                    onPressed: _showAttachmentOptions,
                  ),
                  if (_messageController.text.isEmpty)
                    IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        color: AppColors.primaryGreen,
                      ),
                      onPressed: () => _pickMedia(ImageSource.camera),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedBuilder(
            animation: _sendButtonAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _sendButtonAnimation.value,
                child: GestureDetector(
                  onTap: _messageController.text.trim().isNotEmpty
                      ? _sendMessage
                      : _startVoiceRecording,
                  onLongPress: _messageController.text.trim().isEmpty
                      ? _startVoiceRecording
                      : null,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _messageController.text.trim().isNotEmpty
                          ? Icons.send
                          : _isRecording
                          ? Icons.stop
                          : Icons.mic,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return SizedBox(
      height: 250,
      child: emoji.EmojiPicker(
        onEmojiSelected: (category, selectedEmoji) {
          _messageController.text += selectedEmoji.emoji;
        },
        config: emoji.Config(height: 250, checkPlatformCompatibility: true),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start the conversation!',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.red.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Refresh the messages
              ref.invalidate(chatMessagesProvider(widget.chat.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview() {
    if (_replyingTo == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: AppColors.primaryGreen, width: 4),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${_replyingTo!.senderName ?? 'Unknown'}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _replyingTo!.content,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => setState(() => _replyingTo = null),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '${_selectedMessages.length} selected',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.reply, color: Colors.white),
            onPressed: _selectedMessages.length == 1
                ? () => _replyToMessage(_selectedMessages.first)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.forward, color: Colors.white),
            onPressed: () => _forwardMessages(_selectedMessages),
          ),
          IconButton(
            icon: const Icon(Icons.star, color: Colors.white),
            onPressed: () => _starMessages(_selectedMessages),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () => _deleteMessages(_selectedMessages),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _formatDate(date),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }

  Widget _buildReplyContent(MessageModel replyMessage) {
    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12, top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: Colors.white.withOpacity(0.5), width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            replyMessage.senderName ?? 'Unknown',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            replyMessage.content,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white.withOpacity(0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Helper methods
  bool _shouldShowSenderInfo(List<MessageModel> messages, int index) {
    if (index == messages.length - 1) return true;

    final current = messages[index];
    final next = messages[index + 1];

    return current.senderId != next.senderId ||
        current.timestamp.difference(next.timestamp).inMinutes > 5;
  }

  bool _shouldShowDateSeparator(List<MessageModel> messages, int index) {
    if (index == messages.length - 1) return true;

    final current = messages[index];
    final next = messages[index + 1];

    return !_isSameDay(current.timestamp, next.timestamp);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Color _getUserColor(String userId) {
    final colors = [
      Colors.red.shade400,
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.teal.shade400,
    ];

    final index = userId.hashCode % colors.length;
    return colors[index.abs()];
  }

  IconData _getMessageStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return Icons.schedule;
      case MessageStatus.sent:
        return Icons.done;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.read:
        return Icons.done_all;
      case MessageStatus.failed:
        return Icons.error_outline;
    }
  }

  Color _getMessageStatusColor(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return Colors.grey;
      case MessageStatus.sent:
        return Colors.grey;
      case MessageStatus.delivered:
        return Colors.white70;
      case MessageStatus.read:
        return Colors.blue;
      case MessageStatus.failed:
        return Colors.red;
    }
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    if (_isSameDay(timestamp, now)) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
    return '${timestamp.day}/${timestamp.month} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (_isSameDay(date, now)) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';

    return '${date.day}/${date.month}/${date.year}';
  }

  // Action methods
  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
      if (_showEmojiPicker) {
        _messageFocusNode.unfocus();
      } else {
        _messageFocusNode.requestFocus();
      }
    });
  }

  void _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    ref
        .read(chatServiceProvider)
        .sendMessage(
          chatId: widget.chat.id,
          type: MessageType.text,
          content: content,
          replyToId: _replyingTo?.id,
          replyToMessage: _replyingTo,
        );

    _messageController.clear();
    setState(() => _replyingTo = null);

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildAttachmentOption(
                        icon: Icons.photo_library,
                        label: 'Gallery',
                        color: Colors.purple,
                        onTap: () => _pickMedia(ImageSource.gallery),
                      ),
                      _buildAttachmentOption(
                        icon: Icons.camera_alt,
                        label: 'Camera',
                        color: Colors.red,
                        onTap: () => _pickMedia(ImageSource.camera),
                      ),
                      _buildAttachmentOption(
                        icon: Icons.description,
                        label: 'Document',
                        color: Colors.blue,
                        onTap: _pickDocument,
                      ),
                      _buildAttachmentOption(
                        icon: Icons.location_on,
                        label: 'Location',
                        color: Colors.green,
                        onTap: _shareLocation,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickMedia(ImageSource source) async {
    // Placeholder implementation
    _showSnackBar('Media picker coming soon!');
  }

  Future<void> _pickDocument() async {
    // Placeholder implementation
    _showSnackBar('Document picker coming soon!');
  }

  Future<void> _startVoiceRecording() async {
    // Placeholder implementation
    _showSnackBar('Voice recording coming soon!');
  }

  void _shareLocation() {
    _showSnackBar('Location sharing coming soon!');
  }

  void _startVideoCall() {
    _showSnackBar('Video call coming soon!');
  }

  void _startVoiceCall() {
    _showSnackBar('Voice call coming soon!');
  }

  void _handleMenuAction(String action) {
    _showSnackBar('$action coming soon!');
  }

  void _handleMessageTap(MessageModel message) {
    if (_isSelectionMode) {
      _toggleMessageSelection(message);
    }
  }

  void _handleMessageLongPress(MessageModel message) {
    if (!_isSelectionMode) {
      setState(() {
        _isSelectionMode = true;
        _selectedMessages.add(message);
      });
    } else {
      _toggleMessageSelection(message);
    }
  }

  void _toggleMessageSelection(MessageModel message) {
    setState(() {
      if (_selectedMessages.contains(message)) {
        _selectedMessages.remove(message);
        if (_selectedMessages.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedMessages.add(message);
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedMessages.clear();
    });
  }

  void _replyToMessage(MessageModel message) {
    setState(() {
      _replyingTo = message;
      _isSelectionMode = false;
      _selectedMessages.clear();
    });
    _messageFocusNode.requestFocus();
  }

  void _forwardMessages(List<MessageModel> messages) {
    _showSnackBar('Message forwarding coming soon!');
    _exitSelectionMode();
  }

  void _starMessages(List<MessageModel> messages) {
    _showSnackBar('Message starring coming soon!');
    _exitSelectionMode();
  }

  void _deleteMessages(List<MessageModel> messages) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Messages'),
        content: Text(
          'Are you sure you want to delete ${messages.length} message(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete messages
              for (final message in messages) {
                ref
                    .read(chatServiceProvider)
                    .deleteMessage(widget.chat.id, message.id);
              }
              _exitSelectionMode();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.primaryGreen),
    );
  }
}
