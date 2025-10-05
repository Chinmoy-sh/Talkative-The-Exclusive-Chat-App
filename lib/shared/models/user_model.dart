import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String profileImageUrl;
  final String bio;
  final bool isOnline;
  final DateTime lastSeen;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status; // online, offline, away, busy
  final Map<String, dynamic> settings;
  final List<String> blockedUsers;
  final String fcmToken;
  final String language;
  final String theme;
  final bool isVerified;
  final Map<String, dynamic> privacy;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phoneNumber = '',
    this.profileImageUrl = '',
    this.bio = '',
    this.isOnline = false,
    required this.lastSeen,
    required this.createdAt,
    required this.updatedAt,
    this.status = 'offline',
    this.settings = const {},
    this.blockedUsers = const [],
    this.fcmToken = '',
    this.language = 'en',
    this.theme = 'system',
    this.isVerified = false,
    this.privacy = const {},
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'isOnline': isOnline,
      'lastSeen': Timestamp.fromDate(lastSeen),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'status': status,
      'settings': settings,
      'blockedUsers': blockedUsers,
      'fcmToken': fcmToken,
      'language': language,
      'theme': theme,
      'isVerified': isVerified,
      'privacy': privacy,
    };
  }

  // Create from JSON from Firestore
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      bio: json['bio'] ?? '',
      isOnline: json['isOnline'] ?? false,
      lastSeen: (json['lastSeen'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: json['status'] ?? 'offline',
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      blockedUsers: List<String>.from(json['blockedUsers'] ?? []),
      fcmToken: json['fcmToken'] ?? '',
      language: json['language'] ?? 'en',
      theme: json['theme'] ?? 'system',
      isVerified: json['isVerified'] ?? false,
      privacy: Map<String, dynamic>.from(json['privacy'] ?? {}),
    );
  }

  // Copy with method for updating fields
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    String? bio,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    Map<String, dynamic>? settings,
    List<String>? blockedUsers,
    String? fcmToken,
    String? language,
    String? theme,
    bool? isVerified,
    Map<String, dynamic>? privacy,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      settings: settings ?? this.settings,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      fcmToken: fcmToken ?? this.fcmToken,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      isVerified: isVerified ?? this.isVerified,
      privacy: privacy ?? this.privacy,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, isOnline: $isOnline)';
  }

  // Helper methods
  String get displayName => name.isNotEmpty ? name : email;

  bool get hasProfileImage => profileImageUrl.isNotEmpty;

  String get initials {
    if (name.isNotEmpty) {
      final names = name.trim().split(' ');
      if (names.length >= 2) {
        return '${names[0][0].toUpperCase()}${names[1][0].toUpperCase()}';
      } else if (names.isNotEmpty) {
        return names[0][0].toUpperCase();
      }
    }
    if (email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return 'U';
  }

  String get lastSeenText {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (isOnline) return 'Online';

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return 'Long time ago';
    }
  }
}

// Message Model
class MessageModel {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String chatId;
  final String content;
  final String type; // text, image, video, audio, document, location, etc.
  final DateTime timestamp;
  final bool isRead;
  final bool isDelivered;
  final bool isDeleted;
  final String? mediaUrl;
  final Map<String, dynamic> metadata;
  final String? replyToMessageId;
  final List<String> reactions;
  final bool isEdited;
  final DateTime? editedAt;

  const MessageModel({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.chatId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.isDelivered = false,
    this.isDeleted = false,
    this.mediaUrl,
    this.metadata = const {},
    this.replyToMessageId,
    this.reactions = const [],
    this.isEdited = false,
    this.editedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'receiverId': receiverId,
      'chatId': chatId,
      'content': content,
      'type': type,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'isDelivered': isDelivered,
      'isDeleted': isDeleted,
      'mediaUrl': mediaUrl,
      'metadata': metadata,
      'replyToMessageId': replyToMessageId,
      'reactions': reactions,
      'isEdited': isEdited,
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json['messageId'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      chatId: json['chatId'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? 'text',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: json['isRead'] ?? false,
      isDelivered: json['isDelivered'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      mediaUrl: json['mediaUrl'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      replyToMessageId: json['replyToMessageId'],
      reactions: List<String>.from(json['reactions'] ?? []),
      isEdited: json['isEdited'] ?? false,
      editedAt: (json['editedAt'] as Timestamp?)?.toDate(),
    );
  }

  MessageModel copyWith({
    String? messageId,
    String? senderId,
    String? receiverId,
    String? chatId,
    String? content,
    String? type,
    DateTime? timestamp,
    bool? isRead,
    bool? isDelivered,
    bool? isDeleted,
    String? mediaUrl,
    Map<String, dynamic>? metadata,
    String? replyToMessageId,
    List<String>? reactions,
    bool? isEdited,
    DateTime? editedAt,
  }) {
    return MessageModel(
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      chatId: chatId ?? this.chatId,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isDelivered: isDelivered ?? this.isDelivered,
      isDeleted: isDeleted ?? this.isDeleted,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      metadata: metadata ?? this.metadata,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      reactions: reactions ?? this.reactions,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
    );
  }
}

// Chat Model
class ChatModel {
  final String chatId;
  final List<String> participants;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String lastMessageSenderId;
  final String chatType; // private, group, broadcast
  final String? groupName;
  final String? groupImageUrl;
  final Map<String, int> unreadCounts;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  final bool isMuted;

  const ChatModel({
    required this.chatId,
    required this.participants,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId = '',
    this.chatType = 'private',
    this.groupName,
    this.groupImageUrl,
    this.unreadCounts = const {},
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
    this.isMuted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : null,
      'lastMessageSenderId': lastMessageSenderId,
      'chatType': chatType,
      'groupName': groupName,
      'groupImageUrl': groupImageUrl,
      'unreadCounts': unreadCounts,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isArchived': isArchived,
      'isMuted': isMuted,
    };
  }

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      chatId: json['chatId'] ?? '',
      participants: List<String>.from(json['participants'] ?? []),
      lastMessage: json['lastMessage'],
      lastMessageTime: (json['lastMessageTime'] as Timestamp?)?.toDate(),
      lastMessageSenderId: json['lastMessageSenderId'] ?? '',
      chatType: json['chatType'] ?? 'private',
      groupName: json['groupName'],
      groupImageUrl: json['groupImageUrl'],
      unreadCounts: Map<String, int>.from(json['unreadCounts'] ?? {}),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isArchived: json['isArchived'] ?? false,
      isMuted: json['isMuted'] ?? false,
    );
  }

  ChatModel copyWith({
    String? chatId,
    List<String>? participants,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastMessageSenderId,
    String? chatType,
    String? groupName,
    String? groupImageUrl,
    Map<String, int>? unreadCounts,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
    bool? isMuted,
  }) {
    return ChatModel(
      chatId: chatId ?? this.chatId,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      chatType: chatType ?? this.chatType,
      groupName: groupName ?? this.groupName,
      groupImageUrl: groupImageUrl ?? this.groupImageUrl,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      isMuted: isMuted ?? this.isMuted,
    );
  }
}
