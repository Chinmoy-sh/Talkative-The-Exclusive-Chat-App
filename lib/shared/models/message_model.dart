import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

enum MessageType {
  text,
  image,
  video,
  audio,
  document,
  location,
  contact,
  voice,
  sticker,
  gif,
  poll,
  reply,
  forward,
}

enum MessageStatus { sending, sent, delivered, read, failed }

class MessageModel {
  final String id;
  final String senderId;
  final String? senderName;
  final String? senderProfileUrl;
  final String chatId;
  final MessageType type;
  final String content;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? fileName;
  final int? fileSize;
  final int? duration; // For audio/video messages
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
  final DateTime? editedAt;
  final MessageStatus status;
  final List<String> readBy;
  final String? replyToId;
  final MessageModel? replyToMessage;
  final List<String> reactions;
  final Map<String, String> reactionsMap; // userId -> reaction
  final bool isForwarded;
  final String? forwardedFrom;
  final bool isDeleted;
  final DateTime? deletedAt;
  final bool isStarred;
  final Map<String, dynamic>? location;
  final Map<String, dynamic>? contact;
  final Map<String, dynamic>? poll;

  const MessageModel({
    required this.id,
    required this.senderId,
    this.senderName,
    this.senderProfileUrl,
    required this.chatId,
    required this.type,
    required this.content,
    this.mediaUrl,
    this.thumbnailUrl,
    this.fileName,
    this.fileSize,
    this.duration,
    this.metadata,
    required this.timestamp,
    this.editedAt,
    this.status = MessageStatus.sending,
    this.readBy = const [],
    this.replyToId,
    this.replyToMessage,
    this.reactions = const [],
    this.reactionsMap = const {},
    this.isForwarded = false,
    this.forwardedFrom,
    this.isDeleted = false,
    this.deletedAt,
    this.isStarred = false,
    this.location,
    this.contact,
    this.poll,
  });

  // Factory constructor to create a new message
  factory MessageModel.create({
    required String senderId,
    required String senderName,
    String? senderProfileUrl,
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
    bool isForwarded = false,
    String? forwardedFrom,
    Map<String, dynamic>? location,
    Map<String, dynamic>? contact,
    Map<String, dynamic>? poll,
  }) {
    return MessageModel(
      id: const Uuid().v4(),
      senderId: senderId,
      senderName: senderName,
      senderProfileUrl: senderProfileUrl,
      chatId: chatId,
      type: type,
      content: content,
      mediaUrl: mediaUrl,
      thumbnailUrl: thumbnailUrl,
      fileName: fileName,
      fileSize: fileSize,
      duration: duration,
      metadata: metadata,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
      replyToId: replyToId,
      replyToMessage: replyToMessage,
      isForwarded: isForwarded,
      forwardedFrom: forwardedFrom,
      location: location,
      contact: contact,
      poll: poll,
    );
  }

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderProfileUrl': senderProfileUrl,
      'chatId': chatId,
      'type': type.name,
      'content': content,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'duration': duration,
      'metadata': metadata,
      'timestamp': Timestamp.fromDate(timestamp),
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'status': status.name,
      'readBy': readBy,
      'replyToId': replyToId,
      'replyToMessage': replyToMessage?.toJson(),
      'reactions': reactions,
      'reactionsMap': reactionsMap,
      'isForwarded': isForwarded,
      'forwardedFrom': forwardedFrom,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
      'isStarred': isStarred,
      'location': location,
      'contact': contact,
      'poll': poll,
    };
  }

  // Create from Firestore document
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'],
      senderProfileUrl: json['senderProfileUrl'],
      chatId: json['chatId'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      content: json['content'] ?? '',
      mediaUrl: json['mediaUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      fileName: json['fileName'],
      fileSize: json['fileSize'],
      duration: json['duration'],
      metadata: json['metadata'],
      timestamp: json['timestamp'] is Timestamp
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      editedAt: json['editedAt'] is Timestamp
          ? (json['editedAt'] as Timestamp).toDate()
          : null,
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      readBy: List<String>.from(json['readBy'] ?? []),
      replyToId: json['replyToId'],
      replyToMessage: json['replyToMessage'] != null
          ? MessageModel.fromJson(json['replyToMessage'])
          : null,
      reactions: List<String>.from(json['reactions'] ?? []),
      reactionsMap: Map<String, String>.from(json['reactionsMap'] ?? {}),
      isForwarded: json['isForwarded'] ?? false,
      forwardedFrom: json['forwardedFrom'],
      isDeleted: json['isDeleted'] ?? false,
      deletedAt: json['deletedAt'] is Timestamp
          ? (json['deletedAt'] as Timestamp).toDate()
          : null,
      isStarred: json['isStarred'] ?? false,
      location: json['location'],
      contact: json['contact'],
      poll: json['poll'],
    );
  }

  // CopyWith method for immutability
  MessageModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderProfileUrl,
    String? chatId,
    MessageType? type,
    String? content,
    String? mediaUrl,
    String? thumbnailUrl,
    String? fileName,
    int? fileSize,
    int? duration,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
    DateTime? editedAt,
    MessageStatus? status,
    List<String>? readBy,
    String? replyToId,
    MessageModel? replyToMessage,
    List<String>? reactions,
    Map<String, String>? reactionsMap,
    bool? isForwarded,
    String? forwardedFrom,
    bool? isDeleted,
    DateTime? deletedAt,
    bool? isStarred,
    Map<String, dynamic>? location,
    Map<String, dynamic>? contact,
    Map<String, dynamic>? poll,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderProfileUrl: senderProfileUrl ?? this.senderProfileUrl,
      chatId: chatId ?? this.chatId,
      type: type ?? this.type,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      duration: duration ?? this.duration,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
      editedAt: editedAt ?? this.editedAt,
      status: status ?? this.status,
      readBy: readBy ?? this.readBy,
      replyToId: replyToId ?? this.replyToId,
      replyToMessage: replyToMessage ?? this.replyToMessage,
      reactions: reactions ?? this.reactions,
      reactionsMap: reactionsMap ?? this.reactionsMap,
      isForwarded: isForwarded ?? this.isForwarded,
      forwardedFrom: forwardedFrom ?? this.forwardedFrom,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      isStarred: isStarred ?? this.isStarred,
      location: location ?? this.location,
      contact: contact ?? this.contact,
      poll: poll ?? this.poll,
    );
  }

  // Utility methods
  bool get isTextMessage => type == MessageType.text;
  bool get isMediaMessage => [
    MessageType.image,
    MessageType.video,
    MessageType.audio,
    MessageType.voice,
  ].contains(type);
  bool get isDocumentMessage => type == MessageType.document;
  bool get isLocationMessage => type == MessageType.location;
  bool get hasReply => replyToId != null;
  bool get hasReactions => reactions.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MessageModel(id: $id, senderId: $senderId, type: $type, content: $content)';
  }
}
