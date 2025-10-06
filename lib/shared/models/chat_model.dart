import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

enum ChatType { private, group, broadcast, channel }

class ChatModel {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final ChatType type;
  final List<String> participants;
  final List<String> admins;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastMessageId;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSender;
  final Map<String, int> unreadCounts;
  final Map<String, DateTime> lastSeenTimes;
  final bool isArchived;
  final bool isMuted;
  final bool isPinned;
  final Map<String, dynamic> settings;
  final String? wallpaper;
  final List<String> typingUsers;
  final bool isDeleted;
  final DateTime? deletedAt;

  const ChatModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.type,
    required this.participants,
    this.admins = const [],
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageId,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSender,
    this.unreadCounts = const {},
    this.lastSeenTimes = const {},
    this.isArchived = false,
    this.isMuted = false,
    this.isPinned = false,
    this.settings = const {},
    this.wallpaper,
    this.typingUsers = const [],
    this.isDeleted = false,
    this.deletedAt,
  });

  // Factory constructor for creating a new private chat
  factory ChatModel.createPrivateChat({
    required String userId1,
    required String userId2,
    String? userName1,
    String? userName2,
  }) {
    final participants = [userId1, userId2];
    participants.sort(); // Sort to ensure consistent ID generation

    return ChatModel(
      id: 'private_${participants[0]}_${participants[1]}',
      name: userName2 ?? 'Private Chat',
      type: ChatType.private,
      participants: participants,
      createdBy: userId1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Factory constructor for creating a new group chat
  factory ChatModel.createGroupChat({
    required String name,
    String? description,
    String? imageUrl,
    required List<String> participants,
    required String createdBy,
    List<String>? admins,
  }) {
    return ChatModel(
      id: const Uuid().v4(),
      name: name,
      description: description,
      imageUrl: imageUrl,
      type: ChatType.group,
      participants: participants,
      admins: admins ?? [createdBy],
      createdBy: createdBy,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'type': type.name,
      'participants': participants,
      'admins': admins,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastMessageId': lastMessageId,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : null,
      'lastMessageSender': lastMessageSender,
      'unreadCounts': unreadCounts,
      'lastSeenTimes': lastSeenTimes.map(
        (key, value) => MapEntry(key, Timestamp.fromDate(value)),
      ),
      'isArchived': isArchived,
      'isMuted': isMuted,
      'isPinned': isPinned,
      'settings': settings,
      'wallpaper': wallpaper,
      'typingUsers': typingUsers,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
    };
  }

  // Create from Firestore document
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
      type: ChatType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ChatType.private,
      ),
      participants: List<String>.from(json['participants'] ?? []),
      admins: List<String>.from(json['admins'] ?? []),
      createdBy: json['createdBy'] ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastMessageId: json['lastMessageId'],
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'] is Timestamp
          ? (json['lastMessageTime'] as Timestamp).toDate()
          : null,
      lastMessageSender: json['lastMessageSender'],
      unreadCounts: Map<String, int>.from(json['unreadCounts'] ?? {}),
      lastSeenTimes:
          (json['lastSeenTimes'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              value is Timestamp ? value.toDate() : DateTime.now(),
            ),
          ) ??
          {},
      isArchived: json['isArchived'] ?? false,
      isMuted: json['isMuted'] ?? false,
      isPinned: json['isPinned'] ?? false,
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      wallpaper: json['wallpaper'],
      typingUsers: List<String>.from(json['typingUsers'] ?? []),
      isDeleted: json['isDeleted'] ?? false,
      deletedAt: json['deletedAt'] is Timestamp
          ? (json['deletedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // CopyWith method for immutability
  ChatModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    ChatType? type,
    List<String>? participants,
    List<String>? admins,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastMessageId,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastMessageSender,
    Map<String, int>? unreadCounts,
    Map<String, DateTime>? lastSeenTimes,
    bool? isArchived,
    bool? isMuted,
    bool? isPinned,
    Map<String, dynamic>? settings,
    String? wallpaper,
    List<String>? typingUsers,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return ChatModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      participants: participants ?? this.participants,
      admins: admins ?? this.admins,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSender: lastMessageSender ?? this.lastMessageSender,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      lastSeenTimes: lastSeenTimes ?? this.lastSeenTimes,
      isArchived: isArchived ?? this.isArchived,
      isMuted: isMuted ?? this.isMuted,
      isPinned: isPinned ?? this.isPinned,
      settings: settings ?? this.settings,
      wallpaper: wallpaper ?? this.wallpaper,
      typingUsers: typingUsers ?? this.typingUsers,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  // Utility methods
  bool get isPrivateChat => type == ChatType.private;
  bool get isGroupChat => type == ChatType.group;
  bool get isBroadcast => type == ChatType.broadcast;
  bool get isChannel => type == ChatType.channel;

  bool isUserAdmin(String userId) => admins.contains(userId);
  bool hasUnreadMessages(String userId) => (unreadCounts[userId] ?? 0) > 0;
  int getUnreadCount(String userId) => unreadCounts[userId] ?? 0;

  String getOtherParticipantId(String currentUserId) {
    if (!isPrivateChat) return '';
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChatModel(id: $id, name: $name, type: $type, participants: ${participants.length})';
  }
}
