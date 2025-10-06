// ignore_for_file: unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../../shared/models/chat_model.dart';
import '../../shared/models/message_model.dart';
import '../../shared/models/user_model.dart';

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

final chatsStreamProvider = StreamProvider<List<ChatModel>>((ref) {
  final chatService = ref.watch(chatServiceProvider);
  return chatService.getChatsStream();
});

final chatMessagesProvider = StreamProvider.family<List<MessageModel>, String>((
  ref,
  chatId,
) {
  final chatService = ref.watch(chatServiceProvider);
  return chatService.getMessagesStream(chatId);
});

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  // Get all chats for current user
  Stream<List<ChatModel>> getChatsStream() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(AppConstants.chatsCollection)
        .where('participants', arrayContains: _currentUserId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatModel.fromJson(doc.data()))
              .toList(),
        );
  }

  // Get messages for a specific chat
  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    return _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.messagesCollection)
        .where('isDeleted', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromJson(doc.data()))
              .toList(),
        );
  }

  // Create or get private chat
  Future<ChatModel> createOrGetPrivateChat(String otherUserId) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final participants = [_currentUserId!, otherUserId];
    participants.sort();
    final chatId = 'private_${participants[0]}_${participants[1]}';

    // Check if chat already exists
    final chatDoc = await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .get();

    if (chatDoc.exists) {
      return ChatModel.fromJson(chatDoc.data()!);
    }

    // Get other user's data
    final otherUserDoc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(otherUserId)
        .get();

    final otherUser = UserModel.fromJson(otherUserDoc.data() ?? {});

    // Create new private chat
    final newChat = ChatModel.createPrivateChat(
      userId1: _currentUserId!,
      userId2: otherUserId,
      userName2: otherUser.name,
    );

    await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .set(newChat.toJson());

    return newChat;
  }

  // Create group chat
  Future<ChatModel> createGroupChat({
    required String name,
    String? description,
    String? imageUrl,
    required List<String> participants,
  }) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final chat = ChatModel.createGroupChat(
      name: name,
      description: description,
      imageUrl: imageUrl,
      participants: [...participants, _currentUserId!],
      createdBy: _currentUserId!,
    );

    await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chat.id)
        .set(chat.toJson());

    return chat;
  }

  // Send message
  Future<void> sendMessage({
    required String chatId,
    required MessageType type,
    required String content,
    String? mediaUrl,
    String? thumbnailUrl,
    String? fileName,
    int? fileSize,
    int? duration,
    Map<String, dynamic>? metadata,
    String? replyToId,
    MessageModel? replyToMessage,
    Map<String, dynamic>? location,
    Map<String, dynamic>? contact,
  }) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    // Get current user data
    final userDoc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(_currentUserId)
        .get();

    final userData = UserModel.fromJson(userDoc.data() ?? {});

    final message = MessageModel.create(
      senderId: _currentUserId!,
      senderName: userData.name,
      senderProfileUrl: userData.profileImageUrl,
      chatId: chatId,
      type: type,
      content: content,
      mediaUrl: mediaUrl,
      thumbnailUrl: thumbnailUrl,
      fileName: fileName,
      fileSize: fileSize,
      duration: duration,
      metadata: metadata,
      replyToId: replyToId,
      replyToMessage: replyToMessage,
      location: location,
      contact: contact,
    );

    final batch = _firestore.batch();

    // Add message to chat messages subcollection
    final messageRef = _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.messagesCollection)
        .doc(message.id);

    batch.set(messageRef, message.toJson());

    // Update chat last message info
    final chatRef = _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId);

    batch.update(chatRef, {
      'lastMessageId': message.id,
      'lastMessage': _getLastMessagePreview(message),
      'lastMessageTime': message.timestamp,
      'lastMessageSender': _currentUserId,
      'updatedAt': DateTime.now(),
    });

    await batch.commit();

    // Update message status to sent
    await _updateMessageStatus(chatId, message.id, MessageStatus.sent);
  }

  // Update message status (sent, delivered, read)
  Future<void> _updateMessageStatus(
    String chatId,
    String messageId,
    MessageStatus status,
  ) async {
    await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.messagesCollection)
        .doc(messageId)
        .update({'status': status.name});
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(
    String chatId,
    List<String> messageIds,
  ) async {
    if (_currentUserId == null) return;

    final batch = _firestore.batch();

    for (String messageId in messageIds) {
      final messageRef = _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId)
          .collection(AppConstants.messagesCollection)
          .doc(messageId);

      batch.update(messageRef, {
        'readBy': FieldValue.arrayUnion([_currentUserId]),
        'status': MessageStatus.read.name,
      });
    }

    // Update chat unread count
    final chatRef = _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId);

    batch.update(chatRef, {
      'unreadCounts.$_currentUserId': 0,
      'lastSeenTimes.$_currentUserId': DateTime.now(),
    });

    await batch.commit();
  }

  // Delete message
  Future<void> deleteMessage(
    String chatId,
    String messageId, {
    bool deleteForEveryone = false,
  }) async {
    final messageRef = _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.messagesCollection)
        .doc(messageId);

    if (deleteForEveryone) {
      await messageRef.update({
        'isDeleted': true,
        'deletedAt': DateTime.now(),
        'content': 'This message was deleted',
      });
    } else {
      // Delete only for current user (add to deleted list)
      await messageRef.update({
        'deletedFor': FieldValue.arrayUnion([_currentUserId]),
      });
    }
  }

  // Edit message
  Future<void> editMessage(
    String chatId,
    String messageId,
    String newContent,
  ) async {
    await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.messagesCollection)
        .doc(messageId)
        .update({'content': newContent, 'editedAt': DateTime.now()});
  }

  // Add reaction to message
  Future<void> addReaction(
    String chatId,
    String messageId,
    String reaction,
  ) async {
    if (_currentUserId == null) return;

    await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.messagesCollection)
        .doc(messageId)
        .update({
          'reactionsMap.$_currentUserId': reaction,
          'reactions': FieldValue.arrayUnion([reaction]),
        });
  }

  // Remove reaction from message
  Future<void> removeReaction(String chatId, String messageId) async {
    if (_currentUserId == null) return;

    final messageRef = _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.messagesCollection)
        .doc(messageId);

    final messageDoc = await messageRef.get();
    final messageData = messageDoc.data();

    if (messageData != null) {
      final reactionsMap = Map<String, String>.from(
        messageData['reactionsMap'] ?? {},
      );
      final oldReaction = reactionsMap[_currentUserId!];

      if (oldReaction != null) {
        reactionsMap.remove(_currentUserId!);

        await messageRef.update({
          'reactionsMap': reactionsMap,
          'reactions': FieldValue.arrayRemove([oldReaction]),
        });
      }
    }
  }

  // Set typing status
  Future<void> setTypingStatus(String chatId, bool isTyping) async {
    if (_currentUserId == null) return;

    final chatRef = _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId);

    if (isTyping) {
      await chatRef.update({
        'typingUsers': FieldValue.arrayUnion([_currentUserId]),
      });
    } else {
      await chatRef.update({
        'typingUsers': FieldValue.arrayRemove([_currentUserId]),
      });
    }
  }

  // Archive/unarchive chat
  Future<void> toggleChatArchive(String chatId) async {
    if (_currentUserId == null) return;

    final chatDoc = await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .get();

    final chat = ChatModel.fromJson(chatDoc.data()!);

    await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .update({'isArchived': !chat.isArchived});
  }

  // Mute/unmute chat
  Future<void> toggleChatMute(String chatId) async {
    if (_currentUserId == null) return;

    final chatDoc = await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .get();

    final chat = ChatModel.fromJson(chatDoc.data()!);

    await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .update({'isMuted': !chat.isMuted});
  }

  // Pin/unpin chat
  Future<void> toggleChatPin(String chatId) async {
    if (_currentUserId == null) return;

    final chatDoc = await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .get();

    final chat = ChatModel.fromJson(chatDoc.data()!);

    await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .update({'isPinned': !chat.isPinned});
  }

  // Delete chat
  Future<void> deleteChat(String chatId) async {
    await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .update({'isDeleted': true, 'deletedAt': DateTime.now()});
  }

  // Get chat by ID
  Future<ChatModel?> getChatById(String chatId) async {
    final chatDoc = await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .get();

    if (chatDoc.exists) {
      return ChatModel.fromJson(chatDoc.data()!);
    }
    return null;
  }

  // Search messages in chat
  Stream<List<MessageModel>> searchMessages(String chatId, String query) {
    return _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.messagesCollection)
        .where('content', isGreaterThanOrEqualTo: query)
        .where('content', isLessThan: '$query\uf8ff')
        .where('isDeleted', isEqualTo: false)
        .orderBy('content')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromJson(doc.data()))
              .toList(),
        );
  }

  // Get last message preview for chat list
  String _getLastMessagePreview(MessageModel message) {
    switch (message.type) {
      case MessageType.text:
        return message.content;
      case MessageType.image:
        return '📷 Photo';
      case MessageType.video:
        return '🎬 Video';
      case MessageType.audio:
        return '🎵 Audio';
      case MessageType.voice:
        return '🎤 Voice message';
      case MessageType.document:
        return '📄 Document';
      case MessageType.location:
        return '📍 Location';
      case MessageType.contact:
        return '👤 Contact';
      case MessageType.sticker:
        return '😊 Sticker';
      case MessageType.gif:
        return '🎯 GIF';
      default:
        return message.content;
    }
  }

  // Send typing indicator
  Future<void> sendTypingIndicator(String chatId, bool isTyping) async {
    if (_currentUserId == null) return;

    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('typing')
          .doc(_currentUserId)
          .set({
            'isTyping': isTyping,
            'timestamp': FieldValue.serverTimestamp(),
            'userId': _currentUserId,
          });
    } catch (e) {
      // ignore: avoid_print
      print('Error sending typing indicator: $e');
    }
  }

  // Get typing indicator stream
  Stream<List<String>> getTypingIndicators(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('typing')
        .where('isTyping', isEqualTo: true)
        .where('userId', isNotEqualTo: _currentUserId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => doc.data()['userId'] as String)
              .toList();
        });
  }
}
